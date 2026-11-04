import FitPassport
import SwiftUI

/// "Benim Modelim": body studio, Fit Passport, privacy and deletion.
struct MyModelView: View {
    @Environment(AppModel.self) private var model
    @State private var confirmDeleteAll = false

    var body: some View {
        @Bindable var model = model
        List {
            Section { ModelPartsBar() }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
            BodyStudioSection()

            Section {
                Toggle("Denemelerimi önerilerde kullan", isOn: $model.passport.learningEnabled)
                    .onChange(of: model.passport.learningEnabled) { model.persistPassport() }
                if model.passport.observations.isEmpty {
                    Text("Henüz deneme kaydı yok. Bir ürünü denedikten sonra karar kartından ekleyebilirsin.")
                        .font(.subheadline).foregroundStyle(Token.textSecondary)
                }
                ForEach(model.passport.observations.reversed()) { obs in
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(obs.productVariantID ?? obs.garmentCategory.displayName) · \(obs.markedSize ?? "-")")
                        Text("\(obs.observedOutcome.displayName)\(obs.affectedRegions.isEmpty ? "" : " · " + obs.affectedRegions.map(\.displayName).sorted().joined(separator: ", "))")
                            .font(.caption).foregroundStyle(Token.textSecondary)
                    }
                    .swipeActions { Button("Sil", role: .destructive) { model.deleteObservation(id: obs.id) } }
                }
                if !model.passport.observations.isEmpty {
                    Button("Fit Passport'u sıfırla", role: .destructive) { model.resetPassport() }
                }
            } header: {
                Text("Fit Passport")
            } footer: {
                Text("Bir markadaki bedenin başka markaya veya başka ürün türüne uygulanmaz.")
            }

            Section {
                Label("Hesap yok, sunucu yok", systemImage: "lock")
                Label("Dolap, vücut, seyahat ve deneme kayıtları yalnız bu cihazda, şifreli kasada", systemImage: "lock.iphone")
                Toggle(isOn: Binding(
                    get: { model.weatherConsent != .revoked },
                    set: { allowed in Task { await model.setWeatherAllowed(allowed) } }
                )) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Dokununca hava tahmini iste")
                        Text("Açıkken yalnız sen dokunduğunda seyahat şehrinin merkezi Apple Weather'a gider.")
                            .font(.caption).foregroundStyle(Token.textSecondary)
                    }
                }
                .accessibilityIdentifier("weatherConsentToggle")
                Button("Bu cihazdaki tüm Kabinsiz verilerini sil", role: .destructive) { confirmDeleteAll = true }
                    .accessibilityIdentifier("deleteAllData")
                if let receipt = model.lastDeletionReceipt {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Silindi: \(receipt.deletedRecordCount) kayıt, \(receipt.destroyedKeyCount) şifreleme anahtarı.")
                        Text("Cihaz yedeklerindeki ve daha önce paylaştığın kopyalar bu işlemle silinemez.")
                            .font(.caption).foregroundStyle(Token.textSecondary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier("deletionReceipt")
                }
            } header: {
                Text("Gizlilik")
            }
        }
        .scrollContentBackground(.hidden)
        .background(Token.surfaceBase)
        .navigationTitle("Benim Modelim")
        .confirmationDialog("Tüm veriler silinsin mi?", isPresented: $confirmDeleteAll, titleVisibility: .visible) {
            Button("Dolap, vücut profili, seyahatler ve Fit Passport silinsin", role: .destructive) { model.deleteAllData() }
        } message: {
            Text("Bu işlem geri alınamaz.")
        }
    }
}

/// v3.2 S09 "Benim Modelim" bar: Beden · Ölçüler · Yüz · Saç. Only the body and its measurements exist
/// in this build; face and hair say so plainly instead of offering a control that does nothing. No face
/// image is taken or sent (v3.2 privacy rules).
struct ModelPartsBar: View {
    enum Part: String, CaseIterable, Identifiable {
        case body = "Beden", measures = "Ölçüler", face = "Yüz", hair = "Saç"
        var id: String { rawValue }
        var symbol: String {
            switch self {
            case .body: "figure.stand"
            case .measures: "ruler"
            case .face: "face.smiling"
            case .hair: "comb"
            }
        }
        var note: String {
            switch self {
            case .body: "3B gövden aşağıda; formunu seç, kaydırıcılarla şekillendir."
            case .measures: "Mezura ölçünü aşağıdaki alana yazarsın; fotoğraftan ölçü çıkarmayız."
            case .face: "Yüz kişiselleştirme bu sürümde yok. Yüz fotoğrafın alınmaz, hiçbir yere gönderilmez."
            case .hair: "Saç seçimi bu sürümde yok; model nötr başla kalır."
            }
        }
        var available: Bool { self == .body || self == .measures }
    }

    @State private var part: Part = .body

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                ForEach(Part.allCases) { p in
                    Button { part = p } label: {
                        VStack(spacing: 4) {
                            Image(systemName: p.symbol).font(.title3)
                            Text(p.rawValue).font(.caption.weight(.semibold))
                        }
                        .frame(maxWidth: .infinity, minHeight: 58)
                        .foregroundStyle(part == p ? Color.white : (p.available ? Atelier.ink : Atelier.ink.opacity(0.45)))
                        .background(part == p ? AnyShapeStyle(Atelier.brand) : AnyShapeStyle(Color.white.opacity(0.7)),
                                    in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(part == p ? .isSelected : [])
                    .accessibilityValue(p.available ? "" : "Bu sürümde yok")
                    .accessibilityIdentifier("modelPart-\(p)")
                }
            }
            Text(part.note).font(.footnote).foregroundStyle(.secondary)
                .accessibilityIdentifier("modelPartNote")
        }
    }
}
