//
//  RedundantBoolTests.swift
//  SwiftFormat
//
//  Created by Enrique Garcia Alvarez on 1/4/25.
//  Copyright © 2025 Nick Lockwood. All rights reserved.
//

import SwiftFormat
import XCTest

class RedundantBoolTests: XCTestCase {
    func testRedundantComparisonWithTrue() throws {
        let input = """
        if isEnabled == true {
            print("Enabled")
        }
        """
        let output = """
        if isEnabled {
            print("Enabled")
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testRedundantComparisonWithFalse() throws {
        let input = """
        if isDisabled == false {
            print("Not Disabled")
        }
        """
        let output = """
        if !isDisabled {
            print("Not Disabled")
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testWhileLoopWithRedundantTrue() throws {
        let input = """
        while running == true {
            doSomething()
        }
        """
        let output = """
        while running {
            doSomething()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testGuardStatementWithRedundantFalse() throws {
        let input = """
        guard status == false else {
            return
        }
        """
        let output = """
        guard !status else {
            return
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    // Additional Test Cases
    func testLetAssignmentWithTrue() throws {
        let input = """
        let isActive = userLoggedIn == true
        """
        let output = """
        let isActive = userLoggedIn
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testLetAssignmentWithFalse() throws {
        let input = """
        let isInactive = userLoggedIn == false
        """
        let output = """
        let isInactive = !userLoggedIn
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testTernaryOperatorWithTrue() throws {
        let input = """
        let status = isOnline == true ? "Online" : "Offline"
        """
        let output = """
        let status = isOnline ? "Online" : "Offline"
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testTernaryOperatorWithFalse() throws {
        let input = """
        let status = isOnline == false ? "Offline" : "Online"
        """
        let output = """
        let status = !isOnline ? "Offline" : "Online"
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testLetAssignmentCombinedVariableWithTrue() throws {
        let input = """
        let isActive = resourceValues.isDirectory == true
        """
        let output = """
        let isActive = resourceValues.isDirectory
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testLetAssignmentCombinedVariableWithFalse() throws {
        let input = """
        let isInactive = resourceValues.isDirectory == false
        """
        let output = """
        let isInactive = !resourceValues.isDirectory
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testMultipleConditionsSeparatorAndWithTrue() throws {
        let input = """
        if isReady == true && isComplete == true {
            proceed()
        }
        """
        let output = """
        if isReady && isComplete {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool,
                       exclude: [.andOperator])
    }

    func testMultipleConditionsSeparatorCommaWithTrue() throws {
        let input = """
        if isReady == true, isComplete == true {
            proceed()
        }
        """
        let output = """
        if isReady, isComplete {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testMultipleConditionsWithFalse() throws {
        let input = """
        if isReady == false || isComplete == false {
            stop()
        }
        """
        let output = """
        if !isReady || !isComplete {
            stop()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testRedundantComparisonWithNotTrue() throws {
        let input = """
        if isEnabled != true {
            print("Not Enabled")
        }
        """
        let output = """
        if !isEnabled {
            print("Not Enabled")
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testRedundantComparisonWithNotFalse() throws {
        let input = """
        if isDisabled != false {
            print("Disabled")
        }
        """
        let output = """
        if isDisabled {
            print("Disabled")
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testWhileLoopWithNotTrue() throws {
        let input = """
        while running != true {
            doSomething()
        }
        """
        let output = """
        while !running {
            doSomething()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testGuardStatementWithNotFalse() throws {
        let input = """
        guard status != false else {
            return
        }
        """
        let output = """
        guard status else {
            return
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testTernaryOperatorWithNotTrue() throws {
        let input = """
        let status = isOnline != true ? "Offline" : "Online"
        """
        let output = """
        let status = !isOnline ? "Offline" : "Online"
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testTernaryOperatorWithNotFalse() throws {
        let input = """
        let status = isOnline != false ? "Online" : "Offline"
        """
        let output = """
        let status = isOnline ? "Online" : "Offline"
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testMultipleConditionsWithNotTrue() throws {
        let input = """
        if isReady != true && isComplete != true {
            stop()
        }
        """
        let output = """
        if !isReady && !isComplete {
            stop()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool,
                       exclude: [.andOperator])
    }

    func testMultipleConditionsWithNotFalse() throws {
        let input = """
        if isReady != false || isComplete != false {
            proceed()
        }
        """
        let output = """
        if isReady || isComplete {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testPropertyBooleanComparisonWithTrue() throws {
        let input = """
        if resourceValues.isDirectory == true {
            print("Is a directory")
        }
        """
        let output = """
        if resourceValues.isDirectory {
            print("Is a directory")
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testPropertyBooleanComparisonWithFalse() throws {
        let input = """
        if resourceValues.isDirectory == false {
            print("Not a directory")
        }
        """
        let output = """
        if !resourceValues.isDirectory {
            print("Not a directory")
        }
        """

        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testPropertyBooleanComparisonWithNotTrue() throws {
        let input = """
        if resourceValues.isDirectory != true {
            print("Not Enabled")
        }
        """
        let output = """
        if !resourceValues.isDirectory {
            print("Not Enabled")
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testPropertyBooleanComparisonWithNotFalse() throws {
        let input = """
        if resourceValues.isDirectory != false {
            print("Disabled")
        }
        """
        let output = """
        if resourceValues.isDirectory {
            print("Disabled")
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testOptionalBooleanComparisonWithNotTrue() throws {
        let input = """
        if resourceValues?.isDirectory != true {
            print("Not Enabled")
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    func testOptionalBooleanComparisonWithNotFalse() throws {
        let input = """
        if resourceValues?.isDirectory != false {
            print("Disabled")
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    func testOptionalParenBooleanComparisonWithNotTrue() throws {
        let input = """
        if options.rules?.contains("wrapEnumCases") == true {
            print("Not Enabled")
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    func testOptionalParenBooleanComparisonWithNotFalse() throws {
        let input = """
        if options.rules?.contains("unusedArguments") == false {
            print("Disabled")
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    func testWhileOptionalBooleanComparisonWithNotTrue() throws {
        let input = """
        while resourceValues?.isDirectory != true {
            print("Not Enabled")
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    func testWhileOptionalBooleanComparisonWithNotFalse() throws {
        let input = """
        while resourceValues?.isDirectory != false {
            print("Disabled")
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    func testLetOptionalBooleanComparisonWithNotTrue() throws {
        let input = """
        let status = resourceValues?.isOnline != true ? "Offline" : "Online"
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    func testLetOptionalBooleanComparisonWithNotFalse() throws {
        let input = """
        let status = resourceValues?.isOnline != false ? "Online" : "Offline"
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    // MARK: - Additional Edge Cases and Negative Tests

    func testFunctionReturnComparison() throws {
        let input = """
        if isReady() == true {
            proceed()
        }
        """
        let output = """
        if isReady() {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testComputedPropertyComparison() throws {
        let input = """
        var isActive: Bool {
            return state == true
        }
        """
        let output = """
        var isActive: Bool {
            return state
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testNestedExpressionComparison() throws {
        let input = """
        if (user.isActive && settings.enabled) == true {
            proceed()
        }
        """
        let output = """
        if (user.isActive && settings.enabled) {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool, exclude: [.andOperator, .redundantParens])
    }

    func testReturnStatementComparison() throws {
        let input = """
        return isValid == true
        """
        let output = """
        return isValid
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testClosureComparison() throws {
        let input = """
        let filtered = items.filter { $0.isEnabled == true }
        """
        let output = """
        let filtered = items.filter { $0.isEnabled }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    // MARK: - Negative Tests (Should NOT be transformed)

    func testArrayLastShouldNotBeTransformed() throws {
        let input = """
        if flags.last == true {
            proceed()
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    func testArrayFirstShouldNotBeTransformed() throws {
        let input = """
        if flags.first == true {
            proceed()
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    func testDictionaryAccessShouldNotBeTransformed() throws {
        let input = """
        if settings["enabled"] == true {
            proceed()
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    func testArraySubscriptShouldNotBeTransformed() throws {
        let input = """
        if flags[0] == true {
            proceed()
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    func testOptionalChainingWithQuestionMarkShouldNotBeTransformed() throws {
        let input = """
        if user?.isActive == true {
            proceed()
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    func testComplexOptionalChainingWithQuestionMarkShouldNotBeTransformed() throws {
        let input = """
        if user?.profile?.settings?.isPublic == true {
            proceed()
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    func testNilCoalescingOperatorShouldNotBeTransformed() throws {
        let input = """
        if (user?.isActive ?? false) == true {
            proceed()
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    func testOptionalMethodCallShouldNotBeTransformed() throws {
        let input = """
        if collection.first() == true {
            proceed()
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    func testOptionalMinMaxShouldNotBeTransformed() throws {
        let input = """
        if values.min() == true {
            proceed()
        }
        """
        testFormatting(for: input, rule: .redundantBool)
    }

    // MARK: - Complex Expression Tests

    func testComplexPropertyAccessComparison() throws {
        let input = """
        if obj.property.subProperty == true {
            proceed()
        }
        """
        let output = """
        if obj.property.subProperty {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testParenthesizedExpressionComparison() throws {
        let input = """
        if (isValid) == true {
            proceed()
        }
        """
        let output = """
        if (isValid) {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool, exclude: [.redundantParens])
    }

    func testMethodCallWithParametersComparison() throws {
        let input = """
        if validator.check(input: data) == true {
            proceed()
        }
        """
        let output = """
        if validator.check(input: data) {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testStaticPropertyComparison() throws {
        let input = """
        if MyClass.isEnabled == true {
            proceed()
        }
        """
        let output = """
        if MyClass.isEnabled {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testSelfPropertyComparison() throws {
        let input = """
        if self.isReady == true {
            proceed()
        }
        """
        let output = """
        if self.isReady {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool, exclude: [.redundantSelf])
    }

    // MARK: - Whitespace Edge Cases

    func testNoSpacesAroundOperator() throws {
        let input = """
        if isEnabled==true {
            proceed()
        }
        """
        let output = """
        if isEnabled {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testMultipleSpacesAroundOperator() throws {
        let input = """
        if isEnabled  ==  true {
            proceed()
        }
        """
        let output = """
        if isEnabled {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testNewlineBeforeOperator() throws {
        let input = """
        if isEnabled
            == true {
            proceed()
        }
        """
        let output = """
        if isEnabled {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testNewlineAfterOperator() throws {
        let input = """
        if isEnabled ==
            true {
            proceed()
        }
        """
        let output = """
        if isEnabled {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    // MARK: - Backtick Identifier Edge Cases

    func testBacktickIdentifierNamedTrue() throws {
        let input = """
        let `true` = false
        if `true` == true {
            proceed()
        }
        """
        // Should NOT transform - `true` is a variable, not a boolean literal
        testFormatting(for: input, rule: .redundantBool)
    }

    func testBacktickIdentifierNamedFalse() throws {
        let input = """
        let `false` = true
        if `false` == false {
            proceed()
        }
        """
        // Should NOT transform - `false` is a variable, not a boolean literal
        testFormatting(for: input, rule: .redundantBool)
    }

    func testPropertyWithBacktickName() throws {
        let input = """
        if obj.`false` == true {
            proceed()
        }
        """
        let output = """
        if obj.`false` {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    // MARK: - Boolean on Left Side

    func testTrueOnLeftSide() throws {
        let input = """
        if true == isEnabled {
            proceed()
        }
        """
        // The yodaConditions rule will swap this to isEnabled == true,
        // then redundantBool will remove == true. Exclude yodaConditions to test just redundantBool.
        testFormatting(for: input, rule: .redundantBool, exclude: [.yodaConditions])
    }

    func testFalseOnLeftSide() throws {
        let input = """
        if false == isEnabled {
            proceed()
        }
        """
        // The yodaConditions rule will swap this to isEnabled == false,
        // then redundantBool will negate it. Exclude yodaConditions to test just redundantBool.
        testFormatting(for: input, rule: .redundantBool, exclude: [.yodaConditions])
    }

    // MARK: - Complex Whitespace in Property Chains

    func testComplexPropertyChainWithWhitespace() throws {
        let input = """
        if obj . property . subProperty == true {
            proceed()
        }
        """
        let output = """
        if obj . property . subProperty {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool, exclude: [.spaceAroundOperators])
    }

    // MARK: - Mixed Optional Chaining

    func testOptionalInMiddleOfChain() throws {
        let input = """
        if user?.settings.isEnabled == true {
            proceed()
        }
        """
        // Should NOT transform - optional chaining makes the result Bool?
        testFormatting(for: input, rule: .redundantBool)
    }

    // MARK: - Comments Between Operator and Boolean

    func testCommentBetweenOperatorAndTrue() throws {
        let input = """
        if isEnabled == /* comment */ true {
            proceed()
        }
        """
        let output = """
        if isEnabled {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testCommentBetweenOperatorAndFalse() throws {
        let input = """
        if isEnabled == /* comment */ false {
            proceed()
        }
        """
        let output = """
        if !isEnabled {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testMultilineCommentBetweenOperatorAndBoolean() throws {
        let input = """
        if isEnabled == /* multi
           line
           comment */ true {
            proceed()
        }
        """
        let output = """
        if isEnabled {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    // MARK: - Multiple Newlines

    func testMultipleNewlinesAfterOperator() throws {
        let input = """
        if isEnabled ==

            true {
            proceed()
        }
        """
        let output = """
        if isEnabled {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testMultipleNewlinesBeforeOperator() throws {
        let input = """
        if isEnabled

            == true {
            proceed()
        }
        """
        let output = """
        if isEnabled {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    // MARK: - Complex Boolean Expressions

    func testComplexBooleanExpressionWithParens() throws {
        let input = """
        if (a && b) == true || (c && d) == false {
            proceed()
        }
        """
        let output = """
        if (a && b) || !(c && d) {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool, exclude: [.andOperator, .redundantParens])
    }

    func testComplexExpressionInTernary() throws {
        let input = """
        let result = (x > 5 && y < 10) == true ? "yes" : "no"
        """
        let output = """
        let result = (x > 5 && y < 10) ? "yes" : "no"
        """
        testFormatting(for: input, output, rule: .redundantBool, exclude: [.andOperator, .redundantParens])
    }

    // MARK: - Force Unwrapped Optionals

    func testForceUnwrappedOptionalWithTrue() throws {
        let input = """
        if optional! == true {
            proceed()
        }
        """
        let output = """
        if optional! {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    func testForceUnwrappedOptionalWithFalse() throws {
        let input = """
        if optional! == false {
            proceed()
        }
        """
        let output = """
        if !optional! {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    // MARK: - Switch Statement Cases

    func testComparisonInSwitchCondition() throws {
        let input = """
        switch value == true {
        case true: break
        case false: break
        }
        """
        let output = """
        switch value {
        case true: break
        case false: break
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    // MARK: - Mixed Whitespace Types

    func testMixedSpacesAndNewlines() throws {
        let input = """
        if isEnabled
            ==
            true {
            proceed()
        }
        """
        let output = """
        if isEnabled {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool)
    }

    // MARK: - Chained Comparisons

    func testMultipleComparisonsInSequence() throws {
        let input = """
        if a == true && b == true && c == false {
            proceed()
        }
        """
        let output = """
        if a && b && !c {
            proceed()
        }
        """
        testFormatting(for: input, output, rule: .redundantBool, exclude: [.andOperator])
    }

    // MARK: - Array/Dictionary with Known Non-Optional Return

    func testNonOptionalSubscript() throws {
        // This test documents current conservative behavior
        // In reality, we can't know if a subscript returns Bool or Bool?
        // without type information, so we conservatively skip all subscripts
        let input = """
        if boolArray[0] == true {
            proceed()
        }
        """
        // Current behavior: does NOT transform (conservative)
        testFormatting(for: input, rule: .redundantBool)
    }
}
