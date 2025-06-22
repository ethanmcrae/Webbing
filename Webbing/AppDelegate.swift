import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
  static var sharedStore: ClipboardStore?
  var menuBar: MenuBarController!
  let hotkeys = HotkeyManager()
  
  func applicationDidFinishLaunching(_ notification: Notification) {
    guard let store = AppDelegate.sharedStore else { return }
    menuBar = MenuBarController(store: store, hotkeys: hotkeys)
    hotkeys.configure(store: store, menuBar: menuBar)
  }
}
