import SwiftUI

struct ToolBarView: View {
  @ObservedObject var store: ClipboardStore
  
  var body: some View {
    HStack(spacing: 12) {
      Button("Clean 24h") { store.cleanseOlderThan24h() }
      Button("Clear All") { store.clearAll() }
      Button(action: openSettings) {
        Image(systemName: "gearshape")
      }
      .buttonStyle(.borderless)
    }
    .buttonStyle(.borderless)
  }
  
  private func openSettings() {
    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
  }
}
