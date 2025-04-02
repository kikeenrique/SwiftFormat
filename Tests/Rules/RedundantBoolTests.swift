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

    
}
