import XCTest
@testable import SwiftStructureInterface

class FileParserTests: XCTestCase {

    var parser: FileParser!

    override func tearDown() {
        parser = nil
        super.tearDown()
    }

    // MARK: - parse

    func test_parse_shouldParseFile() {
        parser = FileParser(fileContents: "protocol P {}")
        let file = parser.parse()
        XCTAssertEqual(file.text, "protocol P {}")
        XCTAssertEqual(file.offset, 0)
        XCTAssertEqual(file.length, 13)
    }

    func test_parse_shouldParseUTF16File() {
        parser = FileParser(fileContents: "protocol 💐 {}")
        let file = parser.parse()
        XCTAssertEqual(file.text, "protocol 💐 {}")
        XCTAssertEqual(file.offset, 0)
        XCTAssertEqual(file.length, 16)
    }

    func test_parse_shouldParseProtocol() {
        parser = FileParser(fileContents: "protocol P {}")
        let file = parser.parse()
        let `protocol` = file.children[0] as? SwiftTypeElement
        XCTAssertEqual(`protocol`?.text, "protocol P {}")
        XCTAssertEqual(`protocol`?.name, "P")
        XCTAssertEqual(`protocol`?.offset, 0)
        XCTAssertEqual(`protocol`?.length, 13)
        XCTAssertEqual(`protocol`?.bodyOffset, 12)
        XCTAssertEqual(`protocol`?.bodyLength, 0)
    }

    func test_parse_shouldParsePartialProtocolWithoutClosingBrace() {
        parser = FileParser(fileContents: "protocol A {")
        let file = parser.parse()
        let `protocol` = file.children[0] as? SwiftTypeElement
        XCTAssertEqual(`protocol`?.text, "protocol A {")
        XCTAssertEqual(`protocol`?.name, "A")
        XCTAssertEqual(`protocol`?.offset, 0)
        XCTAssertEqual(`protocol`?.length, 12)
        XCTAssertEqual(`protocol`?.bodyOffset, 12)
        XCTAssertEqual(`protocol`?.bodyLength, 0)
    }

    func test_parse_shouldParsePartialProtocolWithoutOpeningBrace() {
        parser = FileParser(fileContents: "protocol A")
        let file = parser.parse()
        let `protocol` = file.children[0] as? SwiftTypeElement
        XCTAssertEqual(`protocol`?.text, "protocol A")
        XCTAssertEqual(`protocol`?.name, "A")
        XCTAssertEqual(`protocol`?.offset, 0)
        XCTAssertEqual(`protocol`?.length, 10)
        XCTAssertEqual(`protocol`?.bodyOffset, 10)
        XCTAssertEqual(`protocol`?.bodyLength, 0)
    }

    func test_parse_shouldParseInheritanceClause() {
        parser = FileParser(fileContents: "protocol A: B {}")
        let file = parser.parse()
        let `protocol` = file.children[0] as? SwiftTypeElement
        XCTAssertEqual(`protocol`?.text, "protocol A: B {}")
        XCTAssertEqual(`protocol`?.name, "A")
        XCTAssertEqual(`protocol`?.offset, 0)
        XCTAssertEqual(`protocol`?.length, 16)
        XCTAssertEqual(`protocol`?.bodyOffset, 15)
        XCTAssertEqual(`protocol`?.bodyLength, 0)
        XCTAssertEqual(`protocol`?.inheritedTypes.count, 1)
        XCTAssertEqual(`protocol`?.inheritedTypes[0].name, "B")
        XCTAssertEqual(`protocol`?.inheritedTypes[0].text, "B")
        XCTAssertEqual(`protocol`?.inheritedTypes[0].offset, 12)
        XCTAssertEqual(`protocol`?.inheritedTypes[0].length, 1)
    }

    func test_parse_shouldParseInheritanceClauseWithMultipleInheritanceTypes() {
        parser = FileParser(fileContents: "protocol A: class, ProtocolB, P💐C {}")
        let file = parser.parse()
        let `protocol` = file.children[0] as? SwiftTypeElement
        XCTAssertEqual(`protocol`?.inheritedTypes.count, 3)
        XCTAssertEqual(`protocol`?.inheritedTypes[0].name, "class")
        XCTAssertEqual(`protocol`?.inheritedTypes[0].text, "class")
        XCTAssertEqual(`protocol`?.inheritedTypes[0].offset, 12)
        XCTAssertEqual(`protocol`?.inheritedTypes[0].length, 5)
        XCTAssertEqual(`protocol`?.inheritedTypes[1].name, "ProtocolB")
        XCTAssertEqual(`protocol`?.inheritedTypes[1].text, "ProtocolB")
        XCTAssertEqual(`protocol`?.inheritedTypes[1].offset, 19)
        XCTAssertEqual(`protocol`?.inheritedTypes[1].length, 9)
        XCTAssertEqual(`protocol`?.inheritedTypes[2].name, "P💐C")
        XCTAssertEqual(`protocol`?.inheritedTypes[2].text, "P💐C")
        XCTAssertEqual(`protocol`?.inheritedTypes[2].offset, 30)
        XCTAssertEqual(`protocol`?.inheritedTypes[2].length, 6)
    }

    func test_parse_shouldParseInheritanceClauseWithNestedTypes() {
        parser = FileParser(fileContents: "protocol A: Nested.Type, Deep.Nested.Type {}")
        let file = parser.parse()
        let `protocol` = file.children[0] as? SwiftTypeElement
        XCTAssertEqual(`protocol`?.inheritedTypes.count, 2)
        XCTAssertEqual(`protocol`?.inheritedTypes[0].name, "Nested.Type")
        XCTAssertEqual(`protocol`?.inheritedTypes[0].text, "Nested.Type")
        XCTAssertEqual(`protocol`?.inheritedTypes[0].offset, 12)
        XCTAssertEqual(`protocol`?.inheritedTypes[0].length, 11)
        XCTAssertEqual(`protocol`?.inheritedTypes[1].name, "Deep.Nested.Type")
        XCTAssertEqual(`protocol`?.inheritedTypes[1].text, "Deep.Nested.Type")
        XCTAssertEqual(`protocol`?.inheritedTypes[1].offset, 25)
        XCTAssertEqual(`protocol`?.inheritedTypes[1].length, 16)
    }

    func test_parse_shouldParseInheritanceTypeAsError_whenTypeIsMissing() {
        parser = FileParser(fileContents: "protocol A: {}")
        let file = parser.parse()
        let `protocol` = file.children[0] as? SwiftTypeElement
        XCTAssertEqual(`protocol`?.inheritedTypes.count, 1)
        XCTAssert(`protocol`?.inheritedTypes[0] === SwiftInheritedType.error)
        XCTAssertEqual(`protocol`?.offset, 0)
        XCTAssertEqual(`protocol`?.length, 14)
        XCTAssertEqual(`protocol`?.bodyOffset, 13)
        XCTAssertEqual(`protocol`?.bodyLength, 0)
    }

    func test_parse_shouldParseProtocolWithoutName() {
        parser = FileParser(fileContents: "protocol {}")
        let file = parser.parse()
        let `protocol` = file.children[0] as? SwiftTypeElement
        XCTAssertEqual(`protocol`?.name, "")
        XCTAssertEqual(`protocol`?.text, "protocol {}")
        XCTAssertEqual(`protocol`?.offset, 0)
        XCTAssertEqual(`protocol`?.length, 11)
        XCTAssertEqual(`protocol`?.bodyOffset, 10)
        XCTAssertEqual(`protocol`?.bodyLength, 0)
    }
}
