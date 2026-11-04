import BodyGeometry
import Octopus
import SwiftUI

/// The body studio (§123 Journey A, §133.1): neutral start → sliders → typed measurements → saved locally.
/// Dragging is direct manipulation: the outline follows the finger with no tween (frequent action), and
/// only discrete jumps (undo, redo, unit) morph briefly. Reduce Motion turns that morph off.
struct BodyStudioSection: View {
    @Environment(AppModel.self) private var model
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var unit: LengthUnit = .centimeters
    @State private var drafts: [BodyParameter: Double] = [:]
    @State private var pendingCommit: [BodyParameter: Task<Void, Never>] = [:]
    /// Saving a typed value closes the keyboard so the changed row is visible again.
    @FocusState private var entryFocused: Bool
    @State private var entryParameter: BodyParameter = .waist
    @State private var entryText = ""
    @State private var confirmDelete = false

    var body: some View {
        Section {
            switch model.bodyStatus {
            case .ready:
                if let profile = model.body { editor(profile) }
            case .noProfile, .closed:
                start
            case .unreadable:
                Label(model.bodyMessage ?? "Vücut profili okunamadı.", systemImage: "exclamationmark.triangle")
                    .foregroundStyle(Token.statusCaution)
                deleteButton
            }
            if let receipt = model.lastBodyDeletionReceipt, model.body == nil {
                Text("Vücut profili ve ondan üretilen çizim silindi (\(receipt.deletedRecordCount) kayıt).")
                    .font(.footnote).foregroundStyle(Token.textSecondary)
                    .accessibilityIdentifier("bodyDeletionReceipt")
            }
        } header: {
            Text("Vücudum")
        } footer: {
            Text("Yalnız bu telefonda, şifreli kasada. Fotoğraf gerekmez. Kaydırıcılar şekli gösterir; beden önerisinde yalnız elle girdiğin ölçüler kullanılır.")
        }
        .onAppear { if let profile = model.body { unit = profile.preferredUnit } }
        .onChange(of: model.body?.preferredUnit) { _, new in if let new { unit = new } }
        .confirmationDialog("Vücut profili silinsin mi?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Vücut profilini ve çizimini sil", role: .destructive) { Task { await model.deleteBody() } }
        } message: {
            Text("Ölçülerin ve ondan üretilen çizim bu cihazdan silinir. Geri alınamaz.")
        }
    }

    // MARK: Start

    private var start: some View {
        VStack(alignment: .leading, spacing: Token.Space.tight) {
            // The unsaved stand-in is already on screen above the list (`BodyFigureHeader`).
            Text("Ölçü zorunlu değil. Bir başlangıç şekliyle başla, sonra kaydırıcılarla kendine benzet.")
                .font(.subheadline).foregroundStyle(Token.textSecondary)
            Text("Başlangıç değerleri bir norm ya da hedef değildir.")
                .font(.footnote).foregroundStyle(Token.textSecondary)
            formPicker(selection: Binding(get: { model.standInForm }, set: { model.standInForm = $0 }), identifier: "startBodyForm")
            Picker("Birim", selection: $unit) {
                ForEach(LengthUnit.allCases, id: \.self) { Text($0.symbol).tag($0) }
            }
            .pickerStyle(.segmented)
            Button("Başlangıç modelini oluştur") { Task { await model.createNeutralBody(unit: unit) } }
                .buttonStyle(PrimaryButtonStyle())
                .accessibilityIdentifier("createNeutralBody")
        }
        .padding(.vertical, 4)
    }

    // MARK: Editor

    @ViewBuilder
    private func editor(_ profile: BodyProfile) -> some View {
        VStack(spacing: Token.Space.tight) {
            if BodyFigureHeader.mesh(model) != nil {
                // The 3D body is above the list (`BodyFigureHeader`), so it stays in view while editing.
            } else {
                // G0 fallback (ADR-007 §5): the 2D outline with the same controls, when the budget says
                // 2D_CARD or the mesh could not be built.
                SilhouetteView(scene: model.bodyScene, heightCm: draftValue(.height, profile), summary: summary(profile))
                    .frame(height: 280)
                    .frame(maxWidth: .infinity)
                    .animation(reduceMotion ? nil : .smooth(duration: 0.28), value: model.bodyScene?.bodyRevision)
            }
            if let scene = model.bodyScene, !scene.isFallback {
                Text(scene.mesh == nil ? "Basit siluet. Görünüm, beden uyumunun kanıtı değildir." : "\(Self.modelName(profile.form)). Görünüm, beden uyumunun kanıtı değildir.")
                    .font(.caption).foregroundStyle(Token.textSecondary)
                    .accessibilityIdentifier("bodyFidelityLabel")
            }
            if let note = model.deviceNote {
                // §113.1 "warn subtly": one quiet line; the controls below keep working.
                Label(note, systemImage: "leaf")
                    .font(.footnote).foregroundStyle(Token.textSecondary)
                    .accessibilityIdentifier("deviceNote")
            }
            if !model.bodyLimitations.isEmpty || model.bodyScene?.isFallback == true {
                Label(model.bodyLimitations.first ?? "Şekil çizilemedi; değerler listede.", systemImage: "info.circle")
                    .font(.footnote).foregroundStyle(Token.textSecondary)
                    .accessibilityIdentifier("bodyLimitation")
            }
            HStack {
                Button { dropDrafts(); Task { await model.undoBody() } } label: { Label("Geri al", systemImage: "arrow.uturn.backward") }
                    .disabled(!model.canUndoBody)
                    .accessibilityIdentifier("bodyUndo")
                Spacer()
                Picker("Birim", selection: $unit) {
                    ForEach(LengthUnit.allCases, id: \.self) { Text($0.symbol).tag($0) }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 140)
                .accessibilityIdentifier("bodyUnit")
                .onChange(of: unit) { _, new in
                    guard new != profile.preferredUnit else { return }
                    Task { await model.setBodyUnit(new) }
                }
                Spacer()
                Button { dropDrafts(); Task { await model.redoBody() } } label: { Label("Yinele", systemImage: "arrow.uturn.forward") }
                    .disabled(!model.canRedoBody)
                    .accessibilityIdentifier("bodyRedo")
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)
        }
        .listRowSeparator(.hidden)

        formPicker(selection: Binding(get: { profile.form }, set: { new in
            guard new != profile.form else { return }
            dropDrafts()
            Task { await model.setBodyForm(new) }
        }), identifier: "bodyForm")

        ForEach(BodyParameter.allCases, id: \.self) { parameter in
            sliderRow(parameter, profile)
        }

        measurementEntry(profile)

        if let message = model.bodyMessage {
            Label(message, systemImage: "exclamationmark.circle")
                .font(.footnote).foregroundStyle(Token.statusCaution)
                .accessibilityIdentifier("bodyMessage")
        }
        deleteButton
    }

    /// Kadın / Erkek / Nötr (ADR-017): the user's choice only. It changes proportions (neck, chest
    /// depth vs width, bust, thighs), never a typed measurement, and is never inferred from anything.
    private func formPicker(selection: Binding<BodyForm>, identifier: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Beden formu").font(.subheadline.weight(.semibold))
            Picker("Beden formu", selection: selection) {
                ForEach(BodyForm.allCases) { Text($0.displayName).tag($0) }
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier(identifier)
            Text("Yalnız senin seçimin. Oranları değiştirir; girdiğin ölçüleri değiştirmez.")
                .font(.caption).foregroundStyle(Token.textSecondary)
        }
        .padding(.vertical, 2)
    }

    /// The fidelity line names the drawn form; the neutral one keeps its old wording.
    private static func modelName(_ form: BodyForm) -> String {
        switch form {
        case .neutral: "Nötr 3B model"
        case .feminine: "3B model, kadın formu"
        case .masculine: "3B model, erkek formu"
        }
    }

    /// What VoiceOver reads for the drawing: the values themselves, not a revision number.
    private func summary(_ profile: BodyProfile) -> String {
        BodyParameter.allCases.map { "\(profile.form.label($0)) \(BodyLength(draftValue($0, profile), .centimeters).formatted(unit))" }
            .joined(separator: ", ")
    }

    private func draftValue(_ p: BodyParameter, _ profile: BodyProfile) -> Double {
        drafts[p] ?? profile[p].length.centimeters
    }

    private func sliderRow(_ p: BodyParameter, _ profile: BodyProfile) -> some View {
        let value = draftValue(p, profile)
        let length = BodyLength(value, .centimeters)
        let range = profile.allowedRange(p)
        return VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline) {
                Text(profile.form.label(p))
                Spacer()
                Text(length.formatted(unit))
                    .monospacedDigit()
                    .contentTransition(.numericText(value: value))
                    .accessibilityIdentifier("value-\(p.rawValue)")
            }
            Slider(
                value: Binding(
                    get: { value },
                    set: { new in
                        drafts[p] = new
                        Task { await model.previewBody(.slider(p, cm: new)) }
                        scheduleCommit(p, cm: new, debounce: true)
                    }
                ),
                in: range, step: BodyParameter.sliderStepCm
            ) { editing in
                if !editing, let v = drafts[p] { scheduleCommit(p, cm: v, debounce: false) }
            }
            .tint(Token.brandInk)
            // A typed measurement is not changed by a stray touch; the user turns it back into a shape on purpose.
            .disabled(profile[p].source == .userMeasured)
            .accessibilityLabel(profile.form.label(p))
            .accessibilityHint(profile[p].source == .userMeasured
                ? "Elle girilmiş ölçü. Değiştirmek için yeni ölçü gir."
                : "Yukarı ya da aşağı kaydırarak yarım santimetre değiştir.")
            .accessibilityValue("\(length.value(in: unit).formatted(.number.precision(.fractionLength(0...1)).locale(Locale(identifier: "tr_TR")))) \(unit.spokenName)")
            .accessibilityIdentifier("slider-\(p.rawValue)")
            HStack {
                Text(profile[p].source.label)
                    .font(.caption2).foregroundStyle(Token.textSecondary)
                if profile[p].source == .userMeasured {
                    Spacer()
                    Button("Kaydırıcıyla şekillendir") {
                        Task { await model.commitBody(.slider(p, cm: profile[p].length.centimeters)) }
                    }
                    .font(.caption2)
                    .buttonStyle(.borderless)
                    .accessibilityHint("Bu değer artık beden önerisinde kullanılmaz.")
                    .accessibilityIdentifier("unlock-\(p.rawValue)")
                }
            }
        }
        .padding(.vertical, 2)
    }

    /// A drag commits on release; anything that changes the value without a drag (VoiceOver adjust,
    /// a tap on the track) commits after a short pause, so no change is ever left unsaved.
    private func scheduleCommit(_ p: BodyParameter, cm: Double, debounce: Bool) {
        pendingCommit[p]?.cancel()
        pendingCommit[p] = Task {
            if debounce {
                try? await Task.sleep(for: .milliseconds(450))
                if Task.isCancelled { return }
            }
            await model.commitBody(.slider(p, cm: cm))
            // A newer drag may have moved the draft on; only clear what this commit saved.
            if drafts[p] == cm { drafts[p] = nil }
        }
    }

    /// Discrete changes (typed value, undo, redo) win over any slider draft still on screen.
    private func dropDrafts(_ only: BodyParameter? = nil) {
        for p in only.map({ [$0] }) ?? BodyParameter.allCases {
            pendingCommit[p]?.cancel()
            pendingCommit[p] = nil
            drafts[p] = nil
        }
    }

    /// Separate rows on purpose: in a List, one row with several controls sends every tap to the first one.
    @ViewBuilder
    private func measurementEntry(_ profile: BodyProfile) -> some View {
        Picker("Ölçü gir", selection: $entryParameter) {
            ForEach(BodyParameter.allCases, id: \.self) { Text($0.displayName).tag($0) }
        }
        .accessibilityIdentifier("measurementParameter")
        let range = profile.allowedRange(entryParameter)
        HStack {
            TextField("Değer (\(unit.symbol))", text: $entryText)
                .keyboardType(.decimalPad)
                .focused($entryFocused)
                .accessibilityIdentifier("measurementValue")
            Button("Kaydet") {
                let raw = entryText.replacingOccurrences(of: ",", with: ".")
                guard let v = Double(raw) else { return }
                let edit = BodyEdit.measured(entryParameter, v, unit)
                entryText = ""
                entryFocused = false
                dropDrafts(entryParameter)
                Task { await model.commitBody(edit) }
            }
            .buttonStyle(.borderless)
            .disabled(Double(entryText.replacingOccurrences(of: ",", with: ".")) == nil)
            .accessibilityIdentifier("saveMeasurement")
        }
        Text("Güvenli aralık: \(BodyLength(range.lowerBound, .centimeters).formatted(unit)) – \(BodyLength(range.upperBound, .centimeters).formatted(unit))")
            .font(.caption).foregroundStyle(Token.textSecondary)
    }

    private var deleteButton: some View {
        Button("Vücut profilini sil", role: .destructive) { confirmDelete = true }
            .accessibilityIdentifier("deleteBody")
    }
}

/// Front-view outline, mirrored from the right half. Scaled so a taller body draws taller in the same
/// frame; there is no face, hair or anatomy to draw (V15-T-BOD-09).
struct SilhouetteView: View {
    let scene: PreviewScene?
    let heightCm: Double
    let summary: String

    var body: some View {
        Canvas { context, size in
            guard let scene, !scene.isFallback, scene.rightOutline.count > 1 else { return }
            let figure = size.height * 0.96 * min(1, max(0.5, heightCm / 220))
            let top = size.height - figure
            let cx = size.width / 2
            var path = Path()
            let right = scene.rightOutline.map { CGPoint(x: cx + $0.x * figure, y: top + $0.y * figure) }
            let left = scene.rightOutline.reversed().map { CGPoint(x: cx - $0.x * figure, y: top + $0.y * figure) }
            // The full outline is dense, so straight segments read as a curve. The lower-detail tier sends
            // only the station anchors; joined by straight lines they look like a needle, so they are drawn
            // as a smooth curve instead (same anchors, no invented shape).
            let smooth = scene.rightOutline.count < 16
            path.move(to: CGPoint(x: cx, y: top))
            Self.add([CGPoint(x: cx, y: top)] + right + [CGPoint(x: cx, y: top + figure)], to: &path, smooth: smooth, minX: cx, maxX: size.width)
            Self.add([CGPoint(x: cx, y: top + figure)] + left + [CGPoint(x: cx, y: top)], to: &path, smooth: smooth, minX: 0, maxX: cx)
            path.closeSubpath()
            context.fill(path, with: .linearGradient(
                Gradient(colors: [Token.accentWarm.opacity(0.55), Token.accentWarm.opacity(0.32)]),
                startPoint: CGPoint(x: cx, y: top), endPoint: CGPoint(x: cx, y: top + figure)))
            context.stroke(path, with: .color(Token.brandInk.opacity(0.7)), lineWidth: 1.2)
            // Leg separation from just below the hip to the ankles, so the shape reads as a person
            // standing, not a dress form. Structural only: a gap, no anatomy.
            let crotch = CGPoint(x: cx, y: top + figure * 0.53)
            let gap = figure * 0.012
            var legs = Path()
            legs.move(to: crotch)
            legs.addQuadCurve(to: CGPoint(x: cx - gap, y: top + figure), control: CGPoint(x: cx - gap * 0.4, y: top + figure * 0.75))
            legs.addLine(to: CGPoint(x: cx + gap, y: top + figure))
            legs.addQuadCurve(to: crotch, control: CGPoint(x: cx + gap * 0.4, y: top + figure * 0.75))
            legs.closeSubpath()
            context.fill(legs, with: .color(Token.surfaceCard))
            context.stroke(legs, with: .color(Token.brandInk.opacity(0.7)), lineWidth: 1.2)
            // Ground line gives the figure weight without decoration.
            var ground = Path()
            ground.move(to: CGPoint(x: cx - figure * 0.22, y: size.height - 1))
            ground.addLine(to: CGPoint(x: cx + figure * 0.22, y: size.height - 1))
            context.stroke(ground, with: .color(Token.borderHairline), lineWidth: 1)
        }
        .accessibilityElement()
        .accessibilityLabel(scene == nil || scene?.isFallback == true
            ? "Vücut çizimi gösterilemiyor; değerler aşağıda"
            : "Vücudunun ön görünüm çizimi")
        .accessibilityValue(summary)
        .accessibilityIdentifier("bodySilhouette")
    }

    /// Appends `points[1...]` to `path`, which already sits at `points[0]`. Smooth mode uses Catmull–Rom
    /// segments as cubic Béziers, with control points clamped to one side of the centre line so the curve
    /// can never cross it or bulge past the canvas.
    static func add(_ points: [CGPoint], to path: inout Path, smooth: Bool, minX: CGFloat, maxX: CGFloat) {
        guard points.count > 1 else { return }
        guard smooth else {
            points.dropFirst().forEach { path.addLine(to: $0) }
            return
        }
        func clamp(_ p: CGPoint) -> CGPoint { CGPoint(x: min(max(p.x, minX), maxX), y: p.y) }
        for i in 0..<(points.count - 1) {
            let p0 = points[max(i - 1, 0)], p1 = points[i], p2 = points[i + 1], p3 = points[min(i + 2, points.count - 1)]
            let c1 = clamp(CGPoint(x: p1.x + (p2.x - p0.x) / 6, y: p1.y + (p2.y - p0.y) / 6))
            let c2 = clamp(CGPoint(x: p2.x - (p3.x - p1.x) / 6, y: p2.y - (p3.y - p1.y) / 6))
            path.addCurve(to: p2, control1: c1, control2: c2)
        }
    }
}

/// The profile's one 3D figure, above the list: the unsaved stand-in before a body exists, then the
/// user's body. It is a single view for the whole screen, never inside a List row and never swapped
/// by `.id`: on the simulator a RealityKit view kept alive by a List cell (out of the window, or
/// scrolled away) blocked the shared RealityKit render thread in `nextDrawable` for a second per
/// frame, so every 3D view froze and touches were dropped (ADR-016 "Bilinen açık", 2026-11-04).
/// Fixed above the list, the figure also stays in view while a slider or a typed value changes it.
struct BodyFigureHeader: View {
    @Environment(AppModel.self) private var model

    /// The mesh to draw, or nil when the 2D outline (in the list) stands in for it.
    static func mesh(_ model: AppModel) -> BodyMesh? {
        if model.bodyStatus == .ready {
            guard let scene = model.bodyScene, !scene.isFallback else { return nil }
            return scene.mesh
        }
        guard model.bodyStatus == .noProfile || model.bodyStatus == .closed else { return nil }
        return model.heroMesh
    }

    var body: some View {
        if let mesh = Self.mesh(model) {
            let isBody = model.bodyStatus == .ready
            BodyModel3DView(mesh: mesh, summary: summary, showsAngleButtons: isBody, identifier: isBody ? "body3D" : "standIn3D")
                .frame(height: 300)
                .frame(maxWidth: .infinity)
                .background(LinearGradient(colors: [Atelier.surfaceSecondary, Atelier.sand], startPoint: .top, endPoint: .bottom),
                            in: RoundedRectangle(cornerRadius: Atelier.Radius.hero, style: .continuous))
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 6)
                // Rows scroll under the figure's strip, so the strip is opaque.
                .background(Token.surfaceBase)
        }
    }

    /// What VoiceOver reads: the saved values themselves, not a revision number.
    private var summary: String {
        guard model.bodyStatus == .ready, let profile = model.body else {
            return "\(model.standInForm.displayName) başlangıç şekli; ölçü girilmedi."
        }
        return BodyParameter.allCases.map { "\(profile.form.label($0)) \(profile[$0].length.formatted(profile.preferredUnit))" }
            .joined(separator: ", ")
    }
}
