import FitPassport
import SwiftUI

/// "Benim Modelim": avatar placeholder, Fit Passport, measurements, privacy and deletion.
struct MyModelView: View {
    @Environment(AppModel.self) private var model
    @State private var confirmDeleteAll = false
    @State private var chest = ""
    @State private var waist = ""

    var body: some View {
        @Bindable var model = model
        List {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Label("3D model bu sürümde yok", systemImage: "cube.transparent").font(.headline)
                    Text("Nötr avatar ve oran düzenleyici sonraki aşamada. Şimdilik kararlar 2D kartlarla.")
                        .font(.subheadline).foregroundStyle(Token.textSecondary)
                }
            }

            Section {
                TextField("Göğüs (cm)", text: $chest).keyboardType(.decimalPad)
                TextField("Bel (cm)", text: $waist).keyboardType(.decimalPad)
                Button("Ölçüleri kaydet") {
                    model.measurements = UserMeasurements(chestCm: Double(chest.replacingOccurrences(of: ",", with: ".")), waistCm: Double(waist.replacingOccurrences(of: ",", with: ".")))
                    model.persistPassport()
                }
            } header: {
                Text("Ölçülerim (isteğe bağlı)")
            } footer: {
                Text("Zorunlu değil. Sadece bu telefonda kalır ve yalnız beden tablosu olan ürünlerde kullanılır.")
            }

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
                Label("Dolap, seyahat ve deneme kayıtları yalnız bu cihazda, şifreli kasada", systemImage: "lock.iphone")
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
        .onAppear {
            chest = model.measurements.chestCm.map { String(format: "%.0f", $0) } ?? ""
            waist = model.measurements.waistCm.map { String(format: "%.0f", $0) } ?? ""
        }
        .confirmationDialog("Tüm veriler silinsin mi?", isPresented: $confirmDeleteAll, titleVisibility: .visible) {
            Button("Dolap, seyahatler ve Fit Passport silinsin", role: .destructive) { model.deleteAllData() }
        } message: {
            Text("Bu işlem geri alınamaz.")
        }
    }
}
