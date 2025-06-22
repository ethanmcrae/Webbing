import SwiftUI

struct PopupView: View {
  enum Mode { case save, paste }
  let mode: PopupMode
  var onCommit: (Int) -> Void
  @State private var keyString = ""
  
  var body: some View {
    TextField("0‑9", text: $keyString)
      .frame(width: 50)
      .textFieldStyle(.plain)
      .multilineTextAlignment(.center)
      .onSubmit {
        if let k = Int(keyString), (0...9).contains(k) {
          onCommit(k)
        }
      }
      .padding(8)
      .background(.ultraThinMaterial)
      .cornerRadius(8)
      .onAppear { DispatchQueue.main.async { NSApp.activate(ignoringOtherApps: true) } }
  }
}
