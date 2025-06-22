import SwiftUI

struct SlotGridView: View {
  @ObservedObject var store: ClipboardStore
  
  private let columns = [GridItem(.adaptive(minimum: 60, maximum: 65))]
  
  var body: some View {
    VStack(spacing: 8) {
      ToolBarView(store: store)
      LazyVGrid(columns: columns, spacing: 8) {
        ForEach(0..<10) { idx in
          ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 8)
              .fill(Color.gray.opacity(0.1))
              .frame(height: 60)
            Text(String(idx))
              .font(.headline)
            if store.slots[idx] != nil {
              Button {
                store.deleteSlot(idx)
              } label: {
                Image(systemName: "xmark.circle.fill")
              }
              .buttonStyle(.borderless)
              .offset(x: 6, y: -6)
            }
          }
          .onTapGesture {
            if let str = store.content(for: idx) {
              NSPasteboard.general.clearContents()
              NSPasteboard.general.setString(str, forType: .string)
            }
          }
        }
      }
      .padding(8)
    }
    .frame(width: 220, height: 260)
  }
}
