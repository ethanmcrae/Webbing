import Carbon
import AppKit

final class HotkeyManager {
  // 1‑based IDs to match registration order
  enum Action: UInt32 { case copy = 1, paste, prev, next, reset }
  
  private var refs: [EventHotKeyRef?] = Array(repeating: nil, count: 5)
  private weak var store: ClipboardStore?
  private weak var menuBar: MenuBarController?
  
  private var currentIndex = 0 { didSet { menuBar?.flash(index: currentIndex) } }
  
  // MARK: ‑ Setup
  func configure(store: ClipboardStore, menuBar: MenuBarController) {
    self.store = store
    self.menuBar = menuBar
    registerHotkeys()
  }
  
  private func registerHotkeys() {
    unregister()
    let mods: UInt32 = UInt32(optionKey + controlKey + cmdKey)
    let map: [(key: UInt32, action: Action)] = [
      (UInt32(kVK_ANSI_C), .copy),
      (UInt32(kVK_ANSI_V), .paste),
      (UInt32(kVK_ANSI_LeftBracket), .prev),
      (UInt32(kVK_ANSI_RightBracket), .next),
      (UInt32(kVK_ANSI_Backslash), .reset)
    ]
    for (idx, pair) in map.enumerated() {
      var hotKeyID = EventHotKeyID(signature: OSType("WBHG".fourCharCodeValue), id: pair.action.rawValue)
      RegisterEventHotKey(pair.key, mods, hotKeyID, GetApplicationEventTarget(), 0, &refs[idx])
    }
    
    var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
    InstallEventHandler(GetApplicationEventTarget(), { (nextHandler, eventRef, userData) in
      guard let userData = userData else { return noErr }
      let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
      var hotKeyID = EventHotKeyID()
      GetEventParameter(eventRef, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID),
                        nil, MemoryLayout.size(ofValue: hotKeyID), nil, &hotKeyID)
      if let action = HotkeyManager.Action(rawValue: hotKeyID.id) {
        Task { @MainActor in
          manager.handle(action)
        }
      }
      return noErr
    }, 1, &eventType, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()), nil)

  }
  
  // MARK: ‑ Actions
  @MainActor private func handle(_ action: Action) {
    switch action {
    case .copy:  performCopy()
    case .paste: performPaste()
    case .prev:  currentIndex = (currentIndex + 9) % 10
    case .next:  currentIndex = (currentIndex + 1) % 10
    case .reset: currentIndex = 0
    }
  }
  
  private func performCopy() {
    // 1. Try responder‑chain copy first
    let copied = NSApp.sendAction(#selector(NSText.copy(_:)), to: nil, from: nil)
    if !copied { // 2. Fallback to synthesized ⌘C
      let src = CGEventSource(stateID: .combinedSessionState)
      let down = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(kVK_ANSI_C), keyDown: true);
      let up   = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(kVK_ANSI_C), keyDown: false);
      down?.flags = .maskCommand; up?.flags = .maskCommand
      down?.post(tap: .cghidEventTap); up?.post(tap: .cghidEventTap)
    }
    // 3. Save after slight delay
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
      guard let self, let str = NSPasteboard.general.string(forType: .string) else { return }
      self.store?.save(str, to: self.currentIndex)
    }
  }
  
  @MainActor private func performPaste() {
    guard let str = store?.content(for: currentIndex) else { return }
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(str, forType: .string)
    let src = CGEventSource(stateID: .combinedSessionState)
    let down = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(kVK_ANSI_V), keyDown: true)
    let up   = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(kVK_ANSI_V), keyDown: false)
    down?.flags = .maskCommand; up?.flags = .maskCommand
    down?.post(tap: .cghidEventTap); up?.post(tap: .cghidEventTap)
  }
  
  private func unregister() { refs.forEach { if let r = $0 { UnregisterEventHotKey(r) } } }
}

extension String {
  var fourCharCodeValue: UInt32 {
    var result: UInt32 = 0
    for char in utf8.prefix(4) { result = (result << 8) + UInt32(char) }
    return result
  }
}
