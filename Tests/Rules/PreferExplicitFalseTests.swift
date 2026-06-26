//
//  PreferExplicitFalseTests.swift
//  SwiftFormatTests
//
//  Created by KYHyeon on 02/08/2026.
//  Copyright © 2026 Nick Lockwood. All rights reserved.
//

import XCTest
@testable import SwiftFormat

final class PreferExplicitFalseTests: XCTestCase {
    func testBasicNegation() {
        let input = """
        if !flag {
            print("false")
        }
        """
        let output = """
        if flag == false {
            print("false")
        }
        """
        testFormatting(for: input, output, rule: .preferExplicitFalse, exclude: [.redundantBool])
    }

    func testGuardNegation() {
        let input = """
        guard !array.isEmpty else { return }
        """
        let output = """
        guard array.isEmpty == false else { return }
        """
        testFormatting(for: input, output, rule: .preferExplicitFalse,
                       exclude: [.wrapConditionalBodies, .redundantBool])
    }

    func testWhileNegation() {
        let input = """
        while !finished {
            doWork()
        }
        """
        let output = """
        while finished == false {
            doWork()
        }
        """
        testFormatting(for: input, output, rule: .preferExplicitFalse, exclude: [.redundantBool])
    }

    func testPropertyNegation() {
        let input = """
        if !view.isHidden {
            view.show()
        }
        """
        let output = """
        if view.isHidden == false {
            view.show()
        }
        """
        testFormatting(for: input, output, rule: .preferExplicitFalse, exclude: [.redundantBool])
    }

    func testFunctionCallNegation() {
        let input = """
        if !foo.bar() {
            handleFalse()
        }
        """
        let output = """
        if foo.bar() == false {
            handleFalse()
        }
        """
        testFormatting(for: input, output, rule: .preferExplicitFalse, exclude: [.redundantBool])
    }

    func testMethodCallNegation() {
        let input = """
        if !array.contains(value) {
            addValue(value)
        }
        """
        let output = """
        if array.contains(value) == false {
            addValue(value)
        }
        """
        testFormatting(for: input, output, rule: .preferExplicitFalse, exclude: [.redundantBool])
    }

    func testParenthesizedExpressionNegation() {
        let input = """
        if !(a && b) {
            handleBothFalse()
        }
        """
        let output = """
        if (a && b) == false {
            handleBothFalse()
        }
        """
        testFormatting(for: input, output, rule: .preferExplicitFalse, exclude: [.redundantBool])
    }

    func testComplexExpressionNegation() {
        let input = """
        if !(foo.bar() && baz.qux()) {
            handleComplexFalse()
        }
        """
        let output = """
        if (foo.bar() && baz.qux()) == false {
            handleComplexFalse()
        }
        """
        testFormatting(for: input, output, rule: .preferExplicitFalse, exclude: [.redundantBool])
    }

    func testNestedPropertyNegation() {
        let input = """
        if !self.view.subviews.isEmpty {
            addSubviews()
        }
        """
        let output = """
        if self.view.subviews.isEmpty == false {
            addSubviews()
        }
        """
        testFormatting(for: input, output, rule: .preferExplicitFalse,
                       exclude: [.redundantSelf, .redundantBool])
    }

    func testChainedMethodCallNegation() {
        let input = """
        if !foo.bar().baz() {
            handleChainedFalse()
        }
        """
        let output = """
        if foo.bar().baz() == false {
            handleChainedFalse()
        }
        """
        testFormatting(for: input, output, rule: .preferExplicitFalse, exclude: [.redundantBool])
    }

    func testMultipleNegationsInSameLine() {
        let input = """
        if !a && !b {
            handleBothFalse()
        }
        """
        let output = """
        if a == false && b == false {
            handleBothFalse()
        }
        """
        testFormatting(for: input, output, rule: .preferExplicitFalse,
                       exclude: [.andOperator, .redundantBool])
    }

    func testNegationInTernary() {
        let input = """
        let result = !condition ? "false" : "true"
        """
        let output = """
        let result = condition == false ? "false" : "true"
        """
        testFormatting(for: input, output, rule: .preferExplicitFalse, exclude: [.redundantBool])
    }

    func testNegationInReturnStatement() {
        let input = """
        func check() -> Bool {
            return !isValid
        }
        """
        let output = """
        func check() -> Bool {
            return isValid == false
        }
        """
        testFormatting(for: input, output, rule: .preferExplicitFalse, exclude: [.redundantBool])
    }

    func testNegationInAssignment() {
        let input = """
        let isFalse = !someCondition
        """
        let output = """
        let isFalse = someCondition == false
        """
        testFormatting(for: input, output, rule: .preferExplicitFalse, exclude: [.redundantBool])
    }

    func testNegationInFunctionParameter() {
        let input = """
        processData(data: !isProcessed)
        """
        let output = """
        processData(data: isProcessed == false)
        """
        testFormatting(for: input, output, rule: .preferExplicitFalse, exclude: [.redundantBool])
    }

    func testNegationWithComments() {
        let input = """
        if !flag { // check if false
            doSomething()
        }
        """
        let output = """
        if flag == false { // check if false
            doSomething()
        }
        """
        testFormatting(for: input, output, rule: .preferExplicitFalse, exclude: [.redundantBool])
    }

    func testNoChangeForPostfixNot() {
        let input = """
        let value = optional!
        """
        testFormatting(for: input, rule: .preferExplicitFalse)
    }

    func testNoChangeForComparisonOperators() {
        let input = """
        if a != b {
            doSomething()
        }
        """
        testFormatting(for: input, rule: .preferExplicitFalse)
    }

    func testNoChangeForExistingEqualFalse() {
        let input = """
        if flag == false {
            doSomething()
        }
        """
        testFormatting(for: input, rule: .preferExplicitFalse, exclude: [.redundantBool])
    }

    func testNoChangeForExistingEqualTrue() {
        let input = """
        if flag == true {
            doSomething()
        }
        """
        testFormatting(for: input, rule: .preferExplicitFalse, exclude: [.redundantBool])
    }

    func testNoChangeForOptionalBool() {
        let input = """
        if optionalBool! {
            doSomething()
        }
        """
        testFormatting(for: input, rule: .preferExplicitFalse)
    }

    func testNoChangeForBinaryNot() {
        let input = """
        let result = ~value
        """
        testFormatting(for: input, rule: .preferExplicitFalse)
    }

    func testSubscriptNegation() {
        let input = """
        if !array[0] {
            processFirstElement()
        }
        """
        let output = """
        if array[0] == false {
            processFirstElement()
        }
        """
        testFormatting(for: input, output, rule: .preferExplicitFalse)
    }

    func testForceUnwrapPropertyNegation() {
        let input = """
        if !foo!.isValid {
            handleInvalidFoo()
        }
        """
        let output = """
        if foo!.isValid == false {
            handleInvalidFoo()
        }
        """
        testFormatting(for: input, output, rule: .preferExplicitFalse, exclude: [.redundantBool])
    }

    func testNegationInClosure() {
        let input = """
        let closure = {
            if !condition {
                return false
            }
            return true
        }
        """
        let output = """
        let closure = {
            if condition == false {
                return false
            }
            return true
        }
        """
        testFormatting(for: input, output, rule: .preferExplicitFalse, exclude: [.wrapFunctionBodies, .redundantBool])
    }

    func testNegationInSwitchCase() {
        let input = """
        switch value {
        case let x where !x.isValid:
            handleInvalid(x)
        default:
            break
        }
        """
        let output = """
        switch value {
        case let x where x.isValid == false:
            handleInvalid(x)
        default:
            break
        }
        """
        testFormatting(for: input, output, rule: .preferExplicitFalse, exclude: [.redundantBool])
    }

    func testNegationInWhereClause() {
        let input = """
        for item in items where !item.isProcessed {
            process(item)
        }
        """
        let output = """
        for item in items where item.isProcessed == false {
            process(item)
        }
        """
        testFormatting(for: input, output, rule: .preferExplicitFalse, exclude: [.redundantBool])
    }

    func testNegationInComputedProperty() {
        let input = """
        var isEmpty: Bool {
            return !items.isEmpty
        }
        """
        let output = """
        var isEmpty: Bool {
            return items.isEmpty == false
        }
        """
        testFormatting(for: input, output, rule: .preferExplicitFalse, exclude: [.redundantBool])
    }

    func testNegationInArrayLiteral() {
        let input = """
        let array = [!a, !b, !c]
        """
        let output = """
        let array = [a == false, b == false, c == false]
        """
        testFormatting(for: input, output, rule: .preferExplicitFalse, exclude: [.redundantBool])
    }

    func testNegationInDictionaryLiteral() {
        let input = """
        let dict = ["a": !value, "b": !other]
        """
        let output = """
        let dict = ["a": value == false, "b": other == false]
        """
        testFormatting(for: input, output, rule: .preferExplicitFalse, exclude: [.redundantBool])
    }

    func testClosureArgumentNegation() {
        let input = """
        let result = !items.contains(where: { $0.isValid })
        """
        let output = """
        let result = items.contains(where: { $0.isValid }) == false
        """
        testFormatting(for: input, output, rule: .preferExplicitFalse, exclude: [.redundantBool])
    }

    func testTrailingClosureNegation() {
        let input = """
        let result = !myArray.contains {
            $0 == value
        }
        """
        let output = """
        let result = myArray.contains {
            $0 == value
        } == false
        """
        testFormatting(for: input, output, rule: .preferExplicitFalse)
    }

    func testNoChangeForNegationBeforeEquals() {
        let input = """
        print(!a == b)
        """
        testFormatting(for: input, rule: .preferExplicitFalse)
    }

    func testNoChangeForNegationBeforeNotEquals() {
        let input = """
        print(!a != b)
        """
        testFormatting(for: input, rule: .preferExplicitFalse)
    }

    func testNoChangeForNegationAfterEquals() {
        let input = """
        print(a == !b)
        """
        testFormatting(for: input, rule: .preferExplicitFalse)
    }

    func testNoChangeForNegationAfterNotEquals() {
        let input = """
        print(a != !b)
        """
        testFormatting(for: input, rule: .preferExplicitFalse)
    }

    func testNoChangeForPreprocessorDirective() {
        let input = """
        #if !DEBUG
        #error("Not supported")
        #endif
        """
        testFormatting(for: input, rule: .preferExplicitFalse, exclude: [.indent])
    }

    func testNoChangeForPreprocessorCanImport() {
        let input = """
        #if !canImport(UIKit)
        #error("UIKit required")
        #endif
        """
        testFormatting(for: input, rule: .preferExplicitFalse, exclude: [.indent])
    }

    func testNoChangeForNegationBeforeIs() {
        let input = """
        print(!foo is Bar)
        """
        testFormatting(for: input, rule: .preferExplicitFalse)
    }

    func testNoChangeForNegationBeforeAs() {
        let input = """
        print(!foo as? Bar)
        """
        testFormatting(for: input, rule: .preferExplicitFalse)
    }

    func testForceUnwrappedNegationBeforeEquals() {
        let input = """
        print(!foo! == bar)
        """
        testFormatting(for: input, rule: .preferExplicitFalse)
    }

    func testDoubleNegationAfterEquals() {
        let input = """
        print(a == !!b)
        """
        testFormatting(for: input, rule: .preferExplicitFalse)
    }
}
