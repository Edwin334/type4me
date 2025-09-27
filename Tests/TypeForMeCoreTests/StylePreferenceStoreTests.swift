import XCTest
@testable import TypeForMeCore

final class StylePreferenceStoreTests: XCTestCase {
    func testLoadReturnsDefaultWhenFileMissing() throws {
        let tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let url = tempDirectory.appendingPathComponent("style.json")
        let store = StylePreferenceStore(fileManager: .default, url: url)

        let preferences = try store.load()

        XCTAssertEqual(preferences, StylePreferences())
    }

    func testSaveThenLoadRoundTrips() throws {
        let tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let url = tempDirectory.appendingPathComponent("style.json")
        let store = StylePreferenceStore(fileManager: .default, url: url)

        let expected = StylePreferences(
            tone: .warm,
            brevity: .long,
            greetings: .custom("Howdy"),
            signOff: .custom("Best, Taylor"),
            avoid: ["jargon", "synergy"]
        )

        try store.save(expected)
        let loaded = try store.load()

        XCTAssertEqual(loaded, expected)
    }
}
