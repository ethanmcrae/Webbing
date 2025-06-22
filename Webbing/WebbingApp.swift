//
//  WebbingApp.swift
//  Webbing
//
//  Created by Ethan McRae on 6/21/25.
//

import SwiftUI
import SwiftData

@main
struct WebbingApp: App {
  // AppDelegate for Carbon hotkeys & menu‑bar lifetime.
  @StateObject var store = ClipboardStore()
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  var body: some Scene {
    Settings {
      SettingsView()
    }
    .environmentObject(store)
  }
}
