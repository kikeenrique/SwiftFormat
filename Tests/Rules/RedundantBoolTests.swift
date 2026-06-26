//
//  RedundantBoolTests.swift
//  SwiftFormat
//
//  Created by Enrique Garcia Alvarez on 1/4/25.
//  Copyright © 2025 Nick Lockwood. All rights reserved.
//

import SwiftFormat
import XCTest

final class RedundantBoolTests: XCTestCase {
    // Syntactically a Bool: parenthesized boolean expressions.

    func testParenthesizedAndWithTrue() {
        let input = """
        if (a && b) == true {
            proceed()
        }
        """
        let output = """
        if (a && b) {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool, exclude: [.redundantParens, .andOperator])
    }

    func testParenthesizedComparisonWithFalse() {
        let input = """
        if (x < y) == false {
            proceed()
        }
        """
        let output = """
        if !(x < y) {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool, exclude: [.redundantParens])
    }

    func testParenthesizedOrWithNotTrue() {
        let input = """
        if (a || b) != true {
            proceed()
        }
        """
        let output = """
        if !(a || b) {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool, exclude: [.redundantParens, .andOperator])
    }

    func testParenthesizedEqualityWithNotFalse() {
        let input = """
        if (a == b) != false {
            proceed()
        }
        """
        let output = """
        if (a == b) {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool, exclude: [.redundantParens])
    }

    func testParenthesizedGreaterThanOrEqual() {
        let input = """
        if (count >= limit) == true {
            proceed()
        }
        """
        let output = """
        if (count >= limit) {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool, exclude: [.redundantParens])
    }

    func testParenthesizedIsCheck() {
        let input = """
        if (value is Foo) == true {
            proceed()
        }
        """
        let output = """
        if (value is Foo) {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool, exclude: [.redundantParens])
    }

    func testNestedParensWithFalse() {
        let input = """
        if ((a) && b) == false {
            proceed()
        }
        """
        let output = """
        if !((a) && b) {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool, exclude: [.redundantParens, .andOperator])
    }

    func testTopLevelComparisonInsideParens() {
        let input = """
        if (foo() == bar()) == true {
            proceed()
        }
        """
        let output = """
        if (foo() == bar()) {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool, exclude: [.redundantParens])
    }

    func testNegationWithinCompoundCondition() {
        let input = """
        if x && (a < b) == false {
            proceed()
        }
        """
        let output = """
        if x && !(a < b) {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool, exclude: [.redundantParens, .andOperator])
    }

    func testMultipleParenthesizedComparisons() {
        let input = """
        if (a && b) == true && (c || d) == false {
            proceed()
        }
        """
        let output = """
        if (a && b) && !(c || d) {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool, exclude: [.redundantParens, .andOperator])
    }

    // Syntactically a Bool: `!`-negated expressions.

    func testNegatedExpressionWithTrue() {
        let input = """
        if !isReady == true {
            proceed()
        }
        """
        let output = """
        if !isReady {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testNegatedExpressionWithFalseCollapses() {
        let input = """
        if !isReady == false {
            proceed()
        }
        """
        let output = """
        if isReady {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testNegatedExpressionWithNotTrueCollapses() {
        let input = """
        if !isReady != true {
            proceed()
        }
        """
        let output = """
        if isReady {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testNegatedMemberChainWithFalseCollapses() {
        let input = """
        if !obj.flag == false {
            proceed()
        }
        """
        let output = """
        if obj.flag {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testNegatedParenthesizedCollapses() {
        let input = """
        if !(a && b) == false {
            proceed()
        }
        """
        let output = """
        if (a && b) {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool, exclude: [.redundantParens, .andOperator])
    }

    // Resolved to a non-optional Bool: function parameters.

    func testFunctionParameterInIf() {
        let input = """
        func handle(isEnabled: Bool) {
            if isEnabled == true {
                proceed()
            }
        }
        """
        let output = """
        func handle(isEnabled: Bool) {
            if isEnabled {
                proceed()
            }
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testFunctionParameterWithFalse() {
        let input = """
        func handle(isEnabled: Bool) {
            if isEnabled == false {
                proceed()
            }
        }
        """
        let output = """
        func handle(isEnabled: Bool) {
            if !isEnabled {
                proceed()
            }
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testFunctionParameterInWhile() {
        let input = """
        func handle(running: Bool) {
            while running == true {
                work()
            }
        }
        """
        let output = """
        func handle(running: Bool) {
            while running {
                work()
            }
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testFunctionParameterInGuard() {
        let input = """
        func handle(valid: Bool) {
            guard valid == false else { return }
            proceed()
        }
        """
        let output = """
        func handle(valid: Bool) {
            guard !valid else { return }
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool,
                       exclude: [.wrapConditionalBodies, .blankLinesAfterGuardStatements])
    }

    func testFunctionParameterInTernary() {
        let input = """
        func describe(online: Bool) -> String {
            online == true ? "On" : "Off"
        }
        """
        let output = """
        func describe(online: Bool) -> String {
            online ? "On" : "Off"
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testFunctionParameterInAssignment() {
        let input = """
        func handle(flag: Bool) {
            let active = flag == true
            use(active)
        }
        """
        let output = """
        func handle(flag: Bool) {
            let active = flag
            use(active)
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testSecondFunctionParameterResolved() {
        let input = """
        func handle(count: Int, enabled: Bool) {
            if enabled == true {
                proceed()
            }
        }
        """
        let output = """
        func handle(count: Int, enabled: Bool) {
            if enabled {
                proceed()
            }
        }
        """
        testFormatting(for: input, output, rule: .redundantBool, exclude: [.unusedArguments])
    }

    func testParameterCapturedInClosure() {
        let input = """
        func handle(flag: Bool) {
            items.forEach { _ in
                if flag == true {
                    proceed()
                }
            }
        }
        """
        let output = """
        func handle(flag: Bool) {
            items.forEach { _ in
                if flag {
                    proceed()
                }
            }
        }
        """
        testFormatting(for: input, output, rule: .redundantBool, exclude: [.preferForLoop])
    }

    // Resolved to a non-optional Bool: local variables.

    func testLocalLetWithBoolAnnotation() {
        let input = """
        func test() {
            let flag: Bool = compute()
            if flag == false {
                proceed()
            }
        }
        """
        let output = """
        func test() {
            let flag: Bool = compute()
            if !flag {
                proceed()
            }
        }
        """
        testFormatting(for: input, output, rule: .redundantBool, exclude: [.redundantType, .propertyTypes])
    }

    func testLocalVarWithTrueLiteral() {
        let input = """
        func test() {
            var flag = true
            if flag == false {
                proceed()
            }
        }
        """
        let output = """
        func test() {
            var flag = true
            if !flag {
                proceed()
            }
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testLocalLetWithFalseLiteral() {
        let input = """
        func test() {
            let flag = false
            if flag == true {
                proceed()
            }
        }
        """
        let output = """
        func test() {
            let flag = false
            if flag {
                proceed()
            }
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    // Resolved to a non-optional Bool: type properties.

    func testSelfStoredPropertyBool() {
        let input = """
        struct Model {
            var isReady: Bool

            func check() {
                if self.isReady == true {
                    proceed()
                }
            }
        }
        """
        let output = """
        struct Model {
            var isReady: Bool

            func check() {
                if self.isReady {
                    proceed()
                }
            }
        }
        """
        testFormatting(for: input, output, rule: .redundantBool, exclude: [.redundantSelf])
    }

    func testBareStoredPropertyBool() {
        let input = """
        struct Model {
            var isReady: Bool

            func check() {
                if isReady == false {
                    proceed()
                }
            }
        }
        """
        let output = """
        struct Model {
            var isReady: Bool

            func check() {
                if !isReady {
                    proceed()
                }
            }
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testComputedPropertyBool() {
        let input = """
        struct Model {
            var isReady: Bool {
                computeReady()
            }

            func check() {
                if isReady == true {
                    proceed()
                }
            }
        }
        """
        let output = """
        struct Model {
            var isReady: Bool {
                computeReady()
            }

            func check() {
                if isReady {
                    proceed()
                }
            }
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testPropertyDeclaredAfterUse() {
        let input = """
        struct Model {
            func check() {
                if isReady == true {
                    proceed()
                }
            }

            var isReady: Bool
        }
        """
        let output = """
        struct Model {
            func check() {
                if isReady {
                    proceed()
                }
            }

            var isReady: Bool
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testPropertyInClassBool() {
        let input = """
        class Model {
            let active: Bool = true

            func check() {
                if active == false {
                    proceed()
                }
            }
        }
        """
        let output = """
        class Model {
            let active: Bool = true

            func check() {
                if !active {
                    proceed()
                }
            }
        }
        """
        testFormatting(for: input, output, rule: .redundantBool, exclude: [.redundantType, .propertyTypes])
    }

    // Resolved to a non-optional Bool: same-file methods returning Bool.

    func testBareMethodCallReturningBool() {
        let input = """
        struct Model {
            func isReady() -> Bool {
                true
            }

            func check() {
                if isReady() == true {
                    proceed()
                }
            }
        }
        """
        let output = """
        struct Model {
            func isReady() -> Bool {
                true
            }

            func check() {
                if isReady() {
                    proceed()
                }
            }
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testSelfMethodCallReturningBool() {
        let input = """
        struct Model {
            func isReady() -> Bool {
                true
            }

            func check() {
                if self.isReady() == false {
                    proceed()
                }
            }
        }
        """
        let output = """
        struct Model {
            func isReady() -> Bool {
                true
            }

            func check() {
                if !self.isReady() {
                    proceed()
                }
            }
        }
        """
        testFormatting(for: input, output, rule: .redundantBool, exclude: [.redundantSelf])
    }

    func testMethodWithArgumentsReturningBool() {
        let input = """
        struct Model {
            func matches(_ value: Int) -> Bool {
                value > 0
            }

            func check() {
                if matches(5) == true {
                    proceed()
                }
            }
        }
        """
        let output = """
        struct Model {
            func matches(_ value: Int) -> Bool {
                value > 0
            }

            func check() {
                if matches(5) {
                    proceed()
                }
            }
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    // Not provable — must NOT be transformed (could break the build).

    func testUnresolvedBareIdentifierNotTransformed() {
        let input = """
        if flag == true {
            proceed()
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    func testMemberOfOtherObjectNotTransformed() {
        let input = """
        func test() {
            if object.isActive == true {
                proceed()
            }
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    func testDeepMemberChainNotTransformed() {
        let input = """
        func test() {
            if a.b.c == true {
                proceed()
            }
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    func testOptionalLocalNotTransformed() {
        let input = """
        func test() {
            let flag: Bool? = compute()
            if flag == true {
                proceed()
            }
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    func testImplicitlyUnwrappedLocalNotTransformed() {
        let input = """
        func test() {
            let flag: Bool! = compute()
            if flag == true {
                proceed()
            }
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    func testOptionalParameterNotTransformed() {
        let input = """
        func handle(flag: Bool?) {
            if flag == true {
                proceed()
            }
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    func testOptionalStoredPropertyNotTransformed() {
        let input = """
        struct Model {
            var flag: Bool?

            func check() {
                if flag == true {
                    proceed()
                }
            }
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    func testOptionalSelfPropertyNotTransformed() {
        let input = """
        struct Model {
            var flag: Bool?

            func check() {
                if self.flag == true {
                    proceed()
                }
            }
        }
        """
        testFormatting(for: input, rule: .redundantBool, exclude: [.redundantSelf])
    }

    func testNonBoolPropertyNotTransformed() {
        let input = """
        struct Model {
            var state: State

            func check() {
                if state == true {
                    proceed()
                }
            }
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    func testMethodReturningOptionalBoolNotTransformed() {
        let input = """
        struct Model {
            func check() -> Bool? {
                nil
            }

            func test() {
                if check() == true {
                    proceed()
                }
            }
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    func testMethodWithNonBoolReturnNotTransformed() {
        let input = """
        struct Model {
            func value() -> Int {
                0
            }

            func test() {
                if value() == true {
                    proceed()
                }
            }
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    func testNonBoolLocalNotTransformed() {
        let input = """
        func test() {
            let flag = compute()
            if flag == true {
                proceed()
            }
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    func testForceUnwrapNotTransformed() {
        let input = """
        func test() {
            if value! == true {
                proceed()
            }
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    func testSubscriptNotTransformed() {
        let input = """
        func test() {
            if dict[key] == true {
                proceed()
            }
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    func testOptionalChainNotTransformed() {
        let input = """
        func test() {
            if user?.isActive == true {
                proceed()
            }
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    func testNilCoalescingNotTransformed() {
        let input = """
        func test() {
            if (flag ?? false) == true {
                proceed()
            }
        }
        """
        testFormatting(for: input, rule: .redundantBool, exclude: [.redundantParens])
    }

    func testAsCastNotTransformed() {
        let input = """
        func test() {
            if (value as? Bool) == true {
                proceed()
            }
        }
        """
        testFormatting(for: input, rule: .redundantBool, exclude: [.redundantParens])
    }

    func testParenthesizedNonBooleanNotTransformed() {
        let input = """
        func test() {
            if (flag) == true {
                proceed()
            }
        }
        """
        testFormatting(for: input, rule: .redundantBool, exclude: [.redundantParens])
    }

    func testCallInParensNotTransformed() {
        let input = """
        func test() {
            if foo(a == b) == true {
                proceed()
            }
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    // Shadowing — a closer binding overrides an outer Bool.

    func testParameterShadowsBoolPropertyNotTransformed() {
        let input = """
        struct Model {
            var flag: Bool

            func handle(flag: OtherType) {
                if flag == true {
                    proceed()
                }
            }
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    func testLocalShadowsBoolParameterNotTransformed() {
        let input = """
        func handle(flag: Bool) {
            let flag = makeOther()
            if flag == true {
                proceed()
            }
        }
        """
        testFormatting(for: input, rule: .redundantBool, exclude: [.unusedArguments])
    }

    func testClosureParameterShadowsBoolPropertyNotTransformed() {
        let input = """
        struct Model {
            var flag: Bool

            func handle() {
                items.forEach { flag in
                    if flag == true {
                        proceed()
                    }
                }
            }
        }
        """
        testFormatting(for: input, rule: .redundantBool, exclude: [.preferForLoop])
    }

    func testForLoopVariableNotTransformed() {
        let input = """
        func handle() {
            for flag in flags {
                if flag == true {
                    proceed()
                }
            }
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    func testTupleBindingNotTransformed() {
        let input = """
        func handle() {
            let (flag, count) = compute()
            if flag == true {
                proceed()
            }
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    func testGuardLetBindingNotTransformed() {
        let input = """
        func handle(value: Bool?) {
            guard let flag = value else { return }
            if flag == true {
                proceed()
            }
        }
        """
        testFormatting(for: input, rule: .redundantBool,
                       exclude: [.wrapConditionalBodies, .blankLinesAfterGuardStatements])
    }

    func testIfLetBindingNotTransformed() {
        let input = """
        func handle(value: Bool?) {
            if let flag = value, flag == true {
                proceed()
            }
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    func testCaseLetBindingNotTransformed() {
        let input = """
        func handle(value: Foo) {
            if case let .some(flag) = value {
                if flag == true {
                    proceed()
                }
            }
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    // Backtick identifiers and non-literal right-hand sides.

    func testBacktickIdentifierOnLeftNotTransformed() {
        let input = """
        func test() {
            if `true` == true {
                proceed()
            }
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    func testBacktickLiteralOnRightNotTransformed() {
        let input = """
        struct Model {
            var ready: Bool

            func check() {
                if ready == `true` {
                    proceed()
                }
            }
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    func testComparisonAgainstNonLiteralNotTransformed() {
        let input = """
        func handle(flag: Bool) {
            if flag == other {
                proceed()
            }
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    // Comments in the affected range are preserved (rule bails out).

    func testCommentBetweenOperatorAndLiteralPreserved() {
        let input = """
        if (a && b) == /* note */ true {
            proceed()
        }
        """
        testFormatting(for: input, rule: .redundantBool, exclude: [.redundantParens, .andOperator])
    }

    func testCommentBeforeOperatorPreserved() {
        let input = """
        if (a && b) /* note */ == true {
            proceed()
        }
        """
        testFormatting(for: input, rule: .redundantBool, exclude: [.redundantParens, .andOperator])
    }

    // Whitespace and newlines around the operator.

    func testNoSpacesAroundOperator() {
        let input = """
        func handle(flag: Bool) {
            if flag==true {
                proceed()
            }
        }
        """
        let output = """
        func handle(flag: Bool) {
            if flag {
                proceed()
            }
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testNewlineAroundOperator() {
        let input = """
        func handle(flag: Bool) {
            if flag
                == true {
                proceed()
            }
        }
        """
        let output = """
        func handle(flag: Bool) {
            if flag {
                proceed()
            }
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }
}
