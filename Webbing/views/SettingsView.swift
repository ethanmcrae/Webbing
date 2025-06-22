import SwiftUI

struct SettingsView: View {
  @AppStorage("saveHotkey") private var saveHotkey = "⌃⌥⌘S"
  @AppStorage("pasteHotkey") private var pasteHotkey = "⌃⌥⌘P"
  
  var body: some View {
    Form {
      Section("Hotkeys") {
        HStack { Text("Save slot") ; TextField("", text: $saveHotkey) }
        HStack { Text("Paste slot") ; TextField("", text: $pasteHotkey) }
      }
      Section("Maintenance") {
        Button("Cleanse entries older than 24h now") {
          NotificationCenter.default.post(name: .init("CleanseNow"), object: nil)
        }
      }
      Text("Webbing v0.1. Made with ❤️.")
        .font(.footnote)
        .foregroundColor(.secondary)
    }
    .padding(20)
    .frame(width: 360)
  }
}
