import XCTest
@testable import RainBarrelLog

@MainActor
final class RainBarrelLogTests: XCTestCase {

    func test_freshStore_hasSeedDataBelowFreeLimit() {
        let store = Store()
        XCTAssertLessThan(store.entries.count, Store.freeLimit)
    }

    func test_freshStore_canAddMore() {
        let store = Store()
        XCTAssertTrue(store.canAddMore)
    }

    func test_add_insertsEntry() {
        let store = Store()
        let before = store.entries.count
        store.add(CheckEntry(date: Date(), fillLevel: "Test Item"))
        XCTAssertEqual(store.entries.count, before + 1)
    }

    func test_add_respectsFreeLimit() {
        let store = Store()
        store.entries = []
        for i in 0..<Store.freeLimit {
            store.add(CheckEntry(date: Date(), fillLevel: "Item \(i)"))
        }
        XCTAssertFalse(store.canAddMore)
        let countAtLimit = store.entries.count
        store.add(CheckEntry(date: Date(), fillLevel: "Overflow"))
        XCTAssertEqual(store.entries.count, countAtLimit)
    }

    func test_isPro_bypassesFreeLimit() {
        let store = Store()
        store.isPro = true
        for i in 0..<(Store.freeLimit + 3) {
            store.add(CheckEntry(date: Date(), fillLevel: "Item \(i)"))
        }
        XCTAssertTrue(store.canAddMore)
    }

    func test_delete_removesEntry() {
        let store = Store()
        let entry = CheckEntry(date: Date(), fillLevel: "Delete Me")
        store.add(entry)
        store.delete(entry)
        XCTAssertFalse(store.entries.contains(where: { $0.id == entry.id }))
    }

    func test_update_modifiesEntry() {
        let store = Store()
        var entry = CheckEntry(date: Date(), fillLevel: "Original")
        store.add(entry)
        entry.fillLevel = "Updated"
        store.update(entry)
        XCTAssertEqual(store.entries.first(where: { $0.id == entry.id })?.fillLevel, "Updated")
    }

    func test_deleteAtOffsets_removesCorrectEntry() {
        let store = Store()
        store.entries = []
        let a = CheckEntry(date: Date(), fillLevel: "A")
        let b = CheckEntry(date: Date(), fillLevel: "B")
        store.entries = [a, b]
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.entries.count, 1)
        XCTAssertEqual(store.entries.first?.id, b.id)
    }
}
