import Foundation
import SwiftUI

@MainActor
final class ClipboardStore: ObservableObject {
  @Published private(set) var slots: [Int: Slot] = [:]
  private let defaultsKey = "WebbingSlots"
  
  init() { load() }
  
  func save(_ content: String, to id: Int) {
    slots[id] = Slot(id: id, content: content, timestamp: .now)
    persist()
  }
  
  func content(for id: Int) -> String? { slots[id]?.content }
  
  func cleanseOlderThan24h() {
    let cutoff = Date().addingTimeInterval(-24*60*60)
    slots = slots.filter { $0.value.timestamp > cutoff }
    persist()
  }
  
  private func persist() {
    if let data = try? JSONEncoder().encode(slots) {
      UserDefaults.standard.set(data, forKey: defaultsKey)
    }
  }
  
  private func load() {
    guard let data = UserDefaults.standard.data(forKey: defaultsKey),
          let dict = try? JSONDecoder().decode([Int: Slot].self, from: data) else { return }
    slots = dict
  }
  
  @MainActor
  func clearAll() {
    slots.removeAll()
    persist()
  }
  
  func deleteSlot(_ id: Int) {
    slots[id] = nil
    persist()
  }
}

struct Slot: Codable, Identifiable {
  let id: Int
  let content: String
  let timestamp: Date
}
