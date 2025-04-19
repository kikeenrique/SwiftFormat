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
}
