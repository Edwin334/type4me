import XCTest
@testable import TypeForMeCore

final class PromptBuilderTests: XCTestCase {
    func testAutowritePayloadOmitsSelection() throws {
        let builder = PromptBuilder()
        let style = StylePreferences(
            tone: .direct,
            brevity: .medium,
            greetings: .none,
            signOff: .custom("Best, Casey"),
            avoid: ["jargon1"]
        )

        let payload = try builder.makePrompt(mode: .autowrite, selection: nil, style: style)
        let jsonObject = try JSONSerialization.jsonObject(with: payload.json, options: []) as? [String: Any]

        XCTAssertEqual(jsonObject?["mode"] as? String, "autowrite")
        XCTAssertNil(jsonObject?["selection"])
        let stylePrefs = jsonObject?["style_prefs"] as? [String: Any]
        XCTAssertEqual(stylePrefs?["tone"] as? String, "direct")
        XCTAssertEqual(stylePrefs?["brevity"] as? String, "medium")
        XCTAssertEqual(stylePrefs?["greetings"] as? String, "none")
        XCTAssertEqual(stylePrefs?["sign_off"] as? String, "Best, Casey")
        XCTAssertEqual(stylePrefs?["avoid"] as? [String], ["jargon1"])
    }

    func testEditPayloadIncludesSelection() throws {
        let builder = PromptBuilder()
        let style = StylePreferences()
        let payload = try builder.makePrompt(mode: .edit, selection: "Some text", style: style)
        let jsonObject = try JSONSerialization.jsonObject(with: payload.json) as? [String: Any]

        XCTAssertEqual(jsonObject?["mode"] as? String, "edit")
        XCTAssertEqual(jsonObject?["selection"] as? String, "Some text")
        XCTAssertNotNil(jsonObject?["style_prefs"] as? [String: Any])
    }
}
