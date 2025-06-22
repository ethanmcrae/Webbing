import AppKit
import SwiftUI

final class MenuBarController {
  private let statusItem: NSStatusItem
  private let popover = NSPopover()
  private var popupWindow: NSWindow?
  
  private let store: ClipboardStore
  private let hotkeys: HotkeyManager
  
  init(store: ClipboardStore, hotkeys: HotkeyManager) {
    self.store = store
    self.hotkeys = hotkeys
    
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    statusItem.button?.image = NSImage(systemSymbolName: "square.on.square", accessibilityDescription: "Webbing")
    statusItem.button?.action = #selector(togglePopover)
    statusItem.button?.target = self
    
    popover.contentSize = NSSize(width: 220, height: 260)
    popover.behavior = .transient
    popover.contentViewController = NSHostingController(rootView: SlotGridView(store: store))
  }
  
  @objc private func togglePopover() {
    if popover.isShown {
      popover.performClose(nil)
    } else if let button = statusItem.button {
      popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
    }
  }
  
  func showPopup(mode: PopupMode) {
    guard let iconFrame = statusItem.button?.window?.frame else { return }
    let view = PopupView(mode: mode) { [weak self] key in
      self?.popover.performClose(nil)
      Task { @MainActor in
        self?.handle(mode: mode, key: key)
      }
    }
    let hosting = NSHostingController(rootView: view)
    let w = NSWindow(contentViewController: hosting)
    w.level = .floating
    w.isOpaque = false
    w.backgroundColor = .clear
    w.makeKeyAndOrderFront(nil)
    w.setFrameOrigin(NSPoint(x: iconFrame.midX - 60, y: iconFrame.maxY - 4))
    popupWindow = w
  }
  
  @MainActor private func handle(mode: PopupMode, key: Int) {
    switch mode {
    case .save:
      if let str = NSPasteboard.general.string(forType: .string) {
        store.save(str, to: key)
      }
    case .paste:
      if let str = store.content(for: key) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(str, forType: .string)
        // Simulate cmd+v
        let src = CGEventSource(stateID: .combinedSessionState)
        let vDown = CGEvent(keyboardEventSource: src, virtualKey: 0x09, keyDown: true) // V key
        let vUp   = CGEvent(keyboardEventSource: src, virtualKey: 0x09, keyDown: false)
        vDown?.flags = .maskCommand
        vUp?.flags   = .maskCommand
        vDown?.post(tap: .cghidEventTap)
        vUp?.post(tap: .cghidEventTap)
      }
    }
  }
}
