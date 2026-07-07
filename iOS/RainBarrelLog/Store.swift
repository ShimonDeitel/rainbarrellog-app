import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var entries: [CheckEntry] = []
    @Published var isPro: Bool = false
    @Published var presentPaywall: Bool = false

    /// Free-tier cap. Seed data ships with well below this count so a fresh
    /// install never hits the paywall immediately.
    static let freeLimit = 8

    private let fileURL: URL = {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("rainbarrellog_entries.json")
    }()

    init() {
        load()
        if entries.isEmpty {
            entries = Store.seedData()
            save()
        }
    }

    var canAddMore: Bool { isPro || entries.count < Store.freeLimit }

    func add(_ entry: CheckEntry) {
        guard canAddMore else { return }
        entries.insert(entry, at: 0)
        save()
    }

    func update(_ entry: CheckEntry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx] = entry
        save()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: CheckEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([CheckEntry].self, from: data) else { return }
        entries = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    static func seedData() -> [CheckEntry] {
        let cal = Calendar.current
        let now = Date()
        return [
            CheckEntry(date: cal.date(byAdding: .day, value: -30, to: now) ?? now, fillLevel: "Sample entry 1", notes: "Getting started"),
            CheckEntry(date: cal.date(byAdding: .day, value: -10, to: now) ?? now, fillLevel: "Sample entry 2", notes: "")
        ]
    }
}
