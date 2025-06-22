//
//  WebbingTests.swift
//  WebbingTests
//
//  Created by Ethan McRae on 6/21/25.
//

import XCTest
@testable import Webbing

final class WebbingTests: XCTestCase {
  func testSaveAndRestore() throws {
    let store = ClipboardStore()
    store.save("hello", to: 1)
    XCTAssertEqual(store.content(for: 1), "hello")
  }
  
  func testCleanse() throws {
    let store = ClipboardStore()
    store.save("old", to: 2)
    store.slots[2]?.timestamp = Date(timeIntervalSinceNow: -25*60*60)
    store.cleanseOlderThan24h()
    XCTAssertNil(store.content(for: 2))
  }
  
  func testIndexCycling() throws {
    let hk = HotkeyManager(); let store = ClipboardStore(); let fakeMenu = MenuBarController(store: store, hotkeys: hk)
    hk.configure(store: store, menuBar: fakeMenu)
    hk.testHandle(.prev)
    XCTAssertEqual(hk.currentIndex, 9)
    hk.testHandle(.next)
    XCTAssertEqual(hk.currentIndex, 0)
    hk.testHandle(.reset)
    XCTAssertEqual(hk.currentIndex, 0)
  }
}
