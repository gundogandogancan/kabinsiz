import FitPassport
import SwiftUI

/// "Benim Modelim": body studio, Fit Passport, privacy and deletion.
struct MyModelView: View {
    @Environment(AppModel.self) private var model
    @State private var confirmDeleteAll = false

    var body: some View {
        @Bindable var model = model
        ScrollViewReader { proxy in
            List {
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
            .onChange(of: model.body == nil) { wasNil, isNil in
                // Just created: show the new figure, not the bottom of the editor where the button was.
                guard wasNil, !isNil else { return }
                Task { @MainActor in
                    // After the editor's rows are in the list; scrolling earlier finds no row.
                    try? await Task.sleep(for: .milliseconds(120))
                    proxy.scrollTo(BodyStudioSection.topRowID, anchor: .top)
                }
            }
        }
        .scrollContentBackground(.hidden)
        // The number pads have no return key; scrolling the page puts the keyboard away.
        .scrollDismissesKeyboard(.immediately)
        .background(Token.surfaceBase)
        .navigationTitle("Benim Modelim")
        .confirmationDialog("Tüm veriler silinsin mi?", isPresented: $confirmDeleteAll, titleVisibility: .visible) {
            Button("Dolap, vücut profili, seyahatler ve Fit Passport silinsin", role: .destructive) { model.deleteAllData() }
        } message: {
            Text("Bu işlem geri alınamaz.")
        }
    }
}
