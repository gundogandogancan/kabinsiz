import AvatarDressing
import SelfModel
import SwiftUI

/// Dress-up (user decision 2026-11-04: "oyun gibi olmalı, ekleyip çıkarabilmeli"). The tray sits under
/// the figure, which stays on screen and can still be turned. Pieces come from the same pool as the
/// swap sheet (the user's closet, or the labelled example closet). Tap a piece to put it on, tap the
/// worn piece to take it off, or drag a piece up and drop it on the figure. Every change can be undone.
struct DressUpTray: View {
    @Environment(AppModel.self) private var model
    @Environment(HomeWorldModel.self) private var world
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.photoGarments) private var photoGarments
    let onDone: () -> Void

    @State private var slot: GarmentSlotID = .top

    var body: some View {
        let slots = world.dressUpSlots(wardrobe: model.wardrobe)
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text("Giydir").font(AtelierType.cardTitle)
                if world.isExample { Text("örnek dolap · sentetik").font(.caption2).foregroundStyle(.secondary) }
                Spacer()
                roundButton("arrow.uturn.backward", "Geri al", id: "dressUndo", enabled: world.dressing.canUndo) { world.undo() }
                roundButton("arrow.uturn.forward", "İleri al", id: "dressRedo", enabled: world.dressing.canRedo) { world.redo() }
                Button("Bitti", action: onDone)
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 14).frame(minHeight: 40)
                    .background(Atelier.brand, in: Capsule())
                    .foregroundStyle(.white)
                    .accessibilityIdentifier("dressDone")
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(slots) { s in
                        Button { withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) { slot = s } } label: {
                            HStack(spacing: 4) {
                                Text(s.displayName)
                                if world.outfit[s] != nil { Circle().fill(Atelier.copper).frame(width: 6, height: 6) }
                            }
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 12).frame(minHeight: 34)
                            .foregroundStyle(slot == s ? .white : Atelier.ink)
                            .background(slot == s ? AnyShapeStyle(Atelier.ink) : AnyShapeStyle(Color.white.opacity(0.8)), in: Capsule())
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(slot == s ? .isSelected : [])
                        .accessibilityValue(world.outfit[s] == nil ? "boş" : "giyili")
                        .accessibilityIdentifier("dressSlot-\(s.rawValue)")
                    }
                }
            }
            items
            Text("Dokun: giy ya da çıkar · Sürükle: modelin üstüne bırak · Temsilî 3B giysi, beden uyumunu göstermez")
                .font(.caption2).foregroundStyle(.secondary)
                .accessibilityIdentifier("dressHint")
        }
        .padding(14)
        .background(Atelier.surface.opacity(0.97), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).strokeBorder(Atelier.copper.opacity(0.25), lineWidth: 0.75))
        .shadow(color: .black.opacity(0.18), radius: 14, y: 6)
        // Open on the outermost worn layer: taking off the coat shows at once what is under it.
        .onAppear {
            if world.outfit[.outerwear] != nil, slots.contains(.outerwear) { slot = .outerwear }
            else if !slots.contains(slot), let first = slots.first { slot = first }
        }
        // A tap on a garment on the figure opens that slot here.
        .onChange(of: world.selectedSlot) { _, picked in if let picked, slots.contains(picked) { slot = picked } }
        .onDisappear { world.selectedSlot = nil }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("dressUpTray")
    }

    @ViewBuilder private var items: some View {
        let pieces = world.choices(for: slot, wardrobe: model.wardrobe)
        if pieces.isEmpty {
            Text("Bu bölüm için dolabında parça yok.").font(.footnote).foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, minHeight: 96, alignment: .leading)
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(pieces) { item in tile(item) }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private func tile(_ item: DressItem) -> some View {
        let worn = world.outfit[item.slot]?.id == item.id
        return Button {
            withAnimation(reduceMotion ? nil : .spring(duration: 0.3)) { world.toggle(item) }
        } label: {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white)
                        .frame(width: 84, height: 92)
                        .overlay { thumb(item) }
                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(worn ? Atelier.copper : Color.black.opacity(0.08), lineWidth: worn ? 2.5 : 1))
                    if worn {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 20))
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, Atelier.copper)
                            .offset(x: 6, y: -6)
                    }
                }
                Text(item.name).font(.caption2.weight(.medium)).lineLimit(1).frame(width: 84)
            }
            .contentShape(.rect)
        }
        .buttonStyle(AtelierPressStyle())
        .draggable(item.id) {
            GarmentThumb(item: item, padding: 4).frame(width: 90, height: 100)
        }
        .accessibilityLabel(item.name)
        .accessibilityValue(worn ? "Üzerinde" : "")
        .accessibilityHint(worn ? "Çıkarmak için dokun" : "Giymek için dokun")
        .accessibilityAddTraits(worn ? .isSelected : [])
        .accessibilityIdentifier("dressItem-\(item.id)")
    }

    /// A garment sewn from a photo shows its own front (the photo's pixels), not the generic drawing.
    @ViewBuilder private func thumb(_ item: DressItem) -> some View {
        if let png = photoGarments[item.id]?.frontPNG, let image = UIImage(data: png) {
            Image(uiImage: image).resizable().scaledToFit().padding(8)
                .accessibilityHidden(true)
        } else {
            GarmentThumb(item: item, padding: 8)
        }
    }

    private func roundButton(_ symbol: String, _ label: String, id: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol).font(.subheadline.weight(.semibold))
                .frame(width: 40, height: 40)
                .background(Color.white.opacity(0.85), in: Circle())
                .foregroundStyle(enabled ? Atelier.ink : Atelier.ink.opacity(0.3))
        }
        .disabled(!enabled)
        .accessibilityLabel(label)
        .accessibilityIdentifier(id)
    }
}
