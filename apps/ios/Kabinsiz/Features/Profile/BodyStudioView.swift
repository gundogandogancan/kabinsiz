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
            Text("Ölçü zorunlu değil. Nötr bir başlangıç şekliyle başla, sonra kaydırıcılarla kendine benzet.")
                .font(.subheadline).foregroundStyle(Token.textSecondary)
            Text("Başlangıç değerleri bir norm ya da hedef değildir.")
                .font(.footnote).foregroundStyle(Token.textSecondary)
            Picker("Birim", selection: $unit) {
                ForEach(LengthUnit.allCases, id: \.self) { Text($0.symbol).tag($0) }
            }
            .pickerStyle(.segmented)
            Button("Nötr başlangıç modeli oluştur") { Task { await model.createNeutralBody(unit: unit) } }
                .buttonStyle(PrimaryButtonStyle())
                .accessibilityIdentifier("createNeutralBody")
        }
        .padding(.vertical, 4)
    }

    // MARK: Editor

    @ViewBuilder
    private func editor(_ profile: BodyProfile) -> some View {
        VStack(spacing: Token.Space.tight) {
            SilhouetteView(scene: model.bodyScene, heightCm: draftValue(.height, profile), summary: summary(profile))
                .frame(height: 280)
                .frame(maxWidth: .infinity)
                .animation(reduceMotion ? nil : .smooth(duration: 0.28), value: model.bodyScene?.bodyRevision)
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

    /// What VoiceOver reads for the drawing: the values themselves, not a revision number.
    private func summary(_ profile: BodyProfile) -> String {
        BodyParameter.allCases.map { "\($0.displayName) \(BodyLength(draftValue($0, profile), .centimeters).formatted(unit))" }
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
                Text(p.displayName)
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
            .accessibilityLabel(p.displayName)
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
                .accessibilityIdentifier("measurementValue")
            Button("Kaydet") {
                let raw = entryText.replacingOccurrences(of: ",", with: ".")
                guard let v = Double(raw) else { return }
                let edit = BodyEdit.measured(entryParameter, v, unit)
                entryText = ""
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
            path.move(to: CGPoint(x: cx, y: top))
            right.forEach { path.addLine(to: $0) }
            path.addLine(to: CGPoint(x: cx, y: top + figure))
            left.forEach { path.addLine(to: $0) }
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
}
