import Carbon
import AppKit

final class HotkeyManager {
  private var saveRef: EventHotKeyRef?
  private var pasteRef: EventHotKeyRef?
  private weak var store: ClipboardStore?
  private weak var menuBar: MenuBarController?
  
  func configure(store: ClipboardStore, menuBar: MenuBarController) {
    self.store = store
    self.menuBar = menuBar
    registerHotkeys()
  }
  
  func registerHotkeys(saveKey: UInt32 = UInt32(kVK_ANSI_S), pasteKey: UInt32 = UInt32(kVK_ANSI_P)) {
    unregister()
    let modifiers: UInt32 = UInt32(optionKey + controlKey + cmdKey)
    let saveHotKeyID = EventHotKeyID(signature: OSType("WEB1".fourCharCodeValue), id: 1)
    RegisterEventHotKey(saveKey, modifiers, saveHotKeyID, GetApplicationEventTarget(), 0, &saveRef)
    
    let pasteHotKeyID = EventHotKeyID(signature: OSType("WEB2".fourCharCodeValue), id: 2)
    RegisterEventHotKey(pasteKey, modifiers, pasteHotKeyID, GetApplicationEventTarget(), 0, &pasteRef)

    
    // Install handler
    var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
    InstallEventHandler(GetApplicationEventTarget(), { (nextHandler, eventRef, userData) in
      var hotKeyID = EventHotKeyID()
      GetEventParameter(eventRef, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hotKeyID)
      if let userData = userData {
        let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
        manager.handle(id: hotKeyID.id)
      }
      return noErr
    }, 1, &eventType, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()), nil)
  }
  
  private func handle(id: UInt32) {
    switch id {
    case 1: menuBar?.showPopup(mode: .save)
    case 2: menuBar?.showPopup(mode: .paste)
    default: break
    }
  }
  
  func unregister() {
    if let saveRef { UnregisterEventHotKey(saveRef) }
    if let pasteRef { UnregisterEventHotKey(pasteRef) }
  }
}

extension String {
  var fourCharCodeValue: FourCharCode {
    var result: FourCharCode = 0
    for (i, c) in utf8.enumerated() {
      result += FourCharCode(c) << ((3-i) * 8)
    }
    return result
  }
}
