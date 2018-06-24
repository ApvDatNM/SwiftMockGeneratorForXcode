import XCTest
@testable import SwiftStructureInterface

class RecursiveElementVisitorTests: XCTestCase {

    var mockVisitor: MockRecursiveVisitor!

    override func setUp() {
        super.setUp()
        mockVisitor = MockRecursiveVisitor()
    }

    override func tearDown() {
        mockVisitor = nil
        super.tearDown()
    }

    // MARK: - visit

    func test_visit_shouldRecursivelyForwardToInnerVisitor() {
        let file = getClassFile() as! File
        let classElement = file.typeDeclarations[0]
        let innerClass = classElement.typeDeclarations[0]
        let innerMethod = innerClass.functionDeclarations[0]
        let innerProperty = innerClass.variableDeclarations[0]
        let method = classElement.functionDeclarations[0]
        let property = classElement.variableDeclarations[0]
        file.accept(mockVisitor)
        XCTAssert(didVisit(file))
        XCTAssert(didVisit(classElement))
        XCTAssert(didVisit(innerClass))
        XCTAssert(didVisit(innerMethod))
        XCTAssert(didVisit(innerProperty))
        XCTAssert(didVisit(method))
        XCTAssert(didVisit(property))

        XCTAssertEqual(getInvokedSwiftTypeDeclarationCount(), 2)
        XCTAssertEqual(getInvokedSwiftTypeDeclaration(at: 0).text, classElement.text)
        XCTAssertEqual(getInvokedSwiftTypeDeclaration(at: 1).text, innerClass.text)

        XCTAssertEqual(getInvokedSwiftFileCount(), 1)
        XCTAssertEqual(getInvokedSwiftFile(at: 0).text, file.text)

        XCTAssertEqual(getInvokedSwiftMethodElementCount(), 2)
        XCTAssertEqual(getInvokedSwiftMethodElement(at: 0).text, innerMethod.text)
        XCTAssertEqual(getInvokedSwiftMethodElement(at: 1).text, method.text)

        XCTAssertEqual(getInvokedSwiftPropertyElementCount(), 2)
        XCTAssertEqual(getInvokedSwiftPropertyElement(at: 0).text, innerProperty.text)
        XCTAssertEqual(getInvokedSwiftPropertyElement(at: 1).text, property.text)
    }

    // MARK: - Helpers

    private func didVisit(_ element: Element) -> Bool {
        return mockVisitor.invokedVisitElementParametersList.contains { $0.element.text == element.text }
    }

    private func getInvokedSwiftTypeDeclaration(at index: Int) -> TypeDeclaration {
        return mockVisitor.invokedVisitTypeDeclarationParametersList[index].element
    }

    private func getInvokedSwiftFile(at index: Int) -> SwiftStructureInterface.File {
        return mockVisitor.invokedVisitFileParametersList[index].element
    }

    private func getInvokedSwiftMethodElement(at index: Int) -> FunctionDeclaration {
        return mockVisitor.invokedVisitFunctionDeclarationParametersList[index].element
    }

    private func getInvokedSwiftPropertyElement(at index: Int) -> VariableDeclaration {
        return mockVisitor.invokedVisitVariableDeclarationParametersList[index].element
    }

    private func getInvokedSwiftElementCount() -> Int {
        return mockVisitor.invokedVisitElementCount
    }

    private func getInvokedSwiftTypeDeclarationCount() -> Int {
        return mockVisitor.invokedVisitTypeDeclarationCount
    }

    private func getInvokedSwiftFileCount() -> Int {
        return mockVisitor.invokedVisitFileCount
    }

    private func getInvokedSwiftMethodElementCount() -> Int {
        return mockVisitor.invokedVisitFunctionDeclarationCount
    }

    private func getInvokedSwiftPropertyElementCount() -> Int {
        return mockVisitor.invokedVisitVariableDeclarationCount
    }

    private func getClassFile() -> Element {
        return SKElementFactoryTestHelper.build(from: getNestedClassString())!
    }

    private func getNestedClassString() -> String {
        return """
class A {

    class B: C, D {

        func innerMethodA() {}
        var propertyB = 0
    }

    func methodA() {}
    var propertyA: Int?
}
"""
    }
}
