import SwiftUI

/// "Nasıl çalışır?" for Dene's local mirror and the switched-off AI video mode.
struct MirrorHowSheet: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List {
                Section("Yerel Ayna") {
                    Text("Ön kamera açılır; vücut duruşun cihazda Apple Vision ile bulunur ve seçtiğin parça bu duruşa göre çizilir.")
                    Text("Kareler kaydedilmez, internete gönderilmez. Ayna kapanınca kamera da kapanır.")
                }
                Section("Ne gösterir, ne göstermez") {
                    Text("Renk ve biçim için temsili bir önizlemedir. Kumaş benzetimi değildir.")
                    Text("Beden ya da kalıp uyumunu göstermez; beden önerisi ayrı ve kanıta dayalıdır.")
                }
                Section("Yapay zekâ video") {
                    Text("Bulut tabanlı video önizleme bu sürümde kapalıdır. Açılırsa önce izin, ücret ve sınırlar ayrıca sorulur.")
                }
            }
            .navigationTitle("Nasıl çalışır?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Kapat") { dismiss() } } }
        }
        .presentationDetents([.medium, .large])
    }
}
