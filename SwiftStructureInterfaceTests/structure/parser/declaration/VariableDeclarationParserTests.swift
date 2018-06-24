import XCTest
@testable import SwiftStructureInterface

class VariableDeclarationParserTests: XCTestCase {

    // MARK: - parse

    func test_parse_shouldParseSimpleVariable() {
        let text = "var a: Int"
        let variable = parse(text)
        XCTAssertEqual(variable.text, text)
        XCTAssertEqual(variable.name, "a")
        XCTAssertEqual(variable.typeAnnotation.text, ": Int")
    }

    func test_parse_shouldParseVariableWithoutName() {
        let text = "var : Int"
        let variable = parse(text)
        XCTAssertEqual(variable.text, text)
        XCTAssertEqual(variable.name, "")
    }

    func test_parse_shouldParseVariableWithoutType() {
        let text = "var a"
        let variable = parse(text)
        XCTAssertEqual(variable.text, text)
        XCTAssertEqual(variable.name, "a")
    }

    func test_parse_shouldParseVariableWithAttributesAndInout() {
        let text = "var a: @a inout Int"
        let variable = parse(text)
        XCTAssertEqual(variable.text, text)
        XCTAssertEqual(variable.name, "a")
    }

    func test_parse_shouldParseVariableWithGetterSetter() {
        let text = "var a: @a inout Int { mutating set @a nonmutating get }"
        let variable = parse(text)
        XCTAssertEqual(variable.text, text)
        XCTAssertEqual(variable.name, "a")
        XCTAssert(variable.isWritable)
    }

    func test_parse_shouldParseVariableWithGetter() {
        let text = "var a: @a inout Int { get }"
        let variable = parse(text)
        XCTAssertEqual(variable.text, text)
        XCTAssertEqual(variable.name, "a")
        XCTAssertFalse(variable.isWritable)
    }

    func test_parse_shouldParseVariableWithAttributesAndModifiers() {
        let text = "@a public weak mutating var a: Int { get }"
        let variable = parse(text)
        XCTAssertEqual(variable.text, text)
        XCTAssertEqual(variable.name, "a")
        XCTAssertFalse(variable.isWritable)
    }

    // MARK: - Helpers

    func parse(_ text: String) -> VariableDeclaration {
        let parser = createDeclarationParser(text, .var, VariableDeclarationParser.self)
        return parser.parse()
    }
}
