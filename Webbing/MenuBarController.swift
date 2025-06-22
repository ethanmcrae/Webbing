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
  
  func flash(index: Int) {
    let hud = NSPanel(contentRect: NSRect(x: 0, y: 0, width: 80, height: 80),
                      styleMask: .borderless, backing: .buffered, defer: false)
    hud.level = .floating
    hud.isOpaque = false
    hud.backgroundColor = .clear
    hud.center()
    hud.contentView = NSHostingView(rootView: HUDView(number: index))
    hud.makeKeyAndOrderFront(nil)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { hud.close() }
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
