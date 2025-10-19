//
//  RedundantBool.swift
//  SwiftFormat
//
//  Created by Enrique Garcia Alvarez on 1/4/25.
//  Copyright © 2025 Nick Lockwood. All rights reserved.
//

import Foundation

public extension FormatRule {
    static let redundantBool = FormatRule(
        help:
        """
        Removes redundant boolean comparisons. Transforms explicit comparisons with `true`/`false` into more concise boolean expressions.
        **Transformations:**
        - `== true` → remove comparison
        - `== false` → add negation (`!`)
        - `!= true` → add negation (`!`)
        - `!= false` → remove comparison

        This rule safely handles optional Bool expressions and will not transform them to avoid compilation errors.
        """,
        options: [],
        sharedOptions: []
    ) { formatter in
        // Properties and methods known to return optional values
        // Using Sets for O(1) membership testing
        let optionalReturningProperties: Set = ["last", "first"]
        let optionalReturningMethods: Set = ["last", "first", "min", "max", "popLast", "popFirst", "randomElement"]

        /// Helper: Check if token at index appears to be an optional-returning expression
        func isOptionalExpression(beforeIndex: Int) -> Bool {
            var checkIndex = beforeIndex

            while let prevIndex = formatter.index(before: checkIndex, where: { !$0.isSpaceOrCommentOrLinebreak }) {
                let token = formatter.tokens[prevIndex]

                // Explicit optional operators: ?, ??, etc.
                if token == .operator("?", .postfix) ||
                   token == .operator("?", .infix) ||
                   token == .operator("??", .infix) {
                    return true
                }

                // Subscript access (dictionary/array)
                if token == .endOfScope("]") {
                    return true
                }

                // Known optional-returning properties
                if token.isIdentifier, optionalReturningProperties.contains(token.string) {
                    return true
                }

                // Known optional-returning methods
                if token == .endOfScope(")"),
                   let methodStartIndex = formatter.index(of: .startOfScope("("), before: prevIndex),
                   let methodNameIndex = formatter.index(before: methodStartIndex, where: { $0.isIdentifier }),
                   optionalReturningMethods.contains(formatter.tokens[methodNameIndex].string) {
                    return true
                }

                checkIndex = prevIndex
            }

            return false
        }

        /// Helper: Check if identifier is a standalone backticked `true` or `false` variable
        func isBacktickedBoolVariable(at index: Int) -> Bool {
            let token = formatter.tokens[index]

            guard token.isIdentifier,
                  token.string.first == "`",
                  token.string == "`true`" || token.string == "`false`" else {
                return false
            }

            // Check if it's a property (obj.`false`) - those are OK to transform
            if let beforeIndex = formatter.index(before: index, where: { !$0.isSpaceOrCommentOrLinebreak }),
               formatter.tokens[beforeIndex] == .operator(".", .infix) {
                return false // It's a property, not a standalone variable
            }

            return true // It's a standalone variable
        }

        /// Helper: Check if the expression is simple enough to safely transform
        func isSimpleExpression(beforeIndex: Int) -> Bool {
            guard let index = formatter.index(before: beforeIndex, where: { !$0.isSpaceOrCommentOrLinebreak }) else {
                return false
            }

            let token = formatter.tokens[index]

            // Allow: identifiers, method calls, force unwraps
            if token.isIdentifier || token == .endOfScope(")") || token == .operator("!", .postfix) {
                // For method calls, check if it's an optional-returning method
                if token == .endOfScope(")"),
                   let methodStartIndex = formatter.index(of: .startOfScope("("), before: index),
                   let methodNameIndex = formatter.index(before: methodStartIndex, where: { $0.isIdentifier }),
                   optionalReturningMethods.contains(formatter.tokens[methodNameIndex].string) {
                    return false // Known optional-returning method
                }
                return true
            }

            return false
        }

        /// Helper: Find the start of the expression for negation placement
        func findExpressionStart(beforeIndex: Int) -> Int {
            var startIndex = beforeIndex

            while let prevIndex = formatter.index(before: startIndex, where: { !$0.isSpaceOrCommentOrLinebreak }) {
                let token = formatter.tokens[prevIndex]

                if token.isIdentifier ||
                   token == .operator(".", .infix) ||
                   token == .endOfScope(")") ||
                   token == .operator("!", .postfix) {
                    startIndex = prevIndex

                    // If we hit a closing paren, jump to the matching opening paren
                    if token == .endOfScope(")"),
                       let openParen = formatter.index(of: .startOfScope("("), before: prevIndex) {
                        startIndex = openParen
                    }
                } else {
                    break
                }
            }

            return startIndex
        }

        /// Helper: Find the range to remove (including whitespace before operator)
        func findRemovalRange(from operatorIndex: Int, to boolIndex: Int) -> ClosedRange<Int> {
            var startIndex = operatorIndex

            // Walk backwards to include all whitespace/comments/newlines before the operator
            var checkIndex = operatorIndex
            while let prevIndex = formatter.index(before: checkIndex, where: { _ in true }),
                  formatter.tokens[prevIndex].isSpaceOrCommentOrLinebreak {
                startIndex = prevIndex
                checkIndex = prevIndex
            }

            return startIndex...boolIndex
        }

        formatter.forEachToken { i, token in
            // Step 1: Check if this is a comparison operator (== or !=)
            guard case let .operator(op, .infix) = token, op == "==" || op == "!=" else {
                return
            }

            // Step 2: Check if the right side is a boolean literal (true or false)
            guard let boolIndex = formatter.index(after: i, where: { !$0.isSpaceOrCommentOrLinebreak }),
                  case let .identifier(boolValue) = formatter.tokens[boolIndex],
                  boolValue == "true" || boolValue == "false",
                  boolValue.first != "`" else { // Skip backticked identifiers
                return
            }

            // Step 3: Skip if the left side appears to return an optional
            guard !isOptionalExpression(beforeIndex: i) else {
                return
            }

            // Step 4: Skip if the left side is a backticked variable named `true` or `false`
            guard let beforeIndex = formatter.index(before: i, where: { !$0.isSpaceOrCommentOrLinebreak }),
                  !isBacktickedBoolVariable(at: beforeIndex) else {
                return
            }

            // Step 5: Skip if the expression is too complex to safely transform
            guard isSimpleExpression(beforeIndex: i) else {
                return
            }

            // Step 6: Find where to place the negation operator (if needed)
            let expressionStart = findExpressionStart(beforeIndex: i)

            // Step 7: Find the range to remove (operator and boolean literal)
            let removalRange = findRemovalRange(from: i, to: boolIndex)

            // Step 8: Apply the transformation based on operator and boolean value
            if boolValue == "true" {
                if op == "==" {
                    // `expr == true` → `expr`
                    formatter.removeTokens(in: removalRange)
                } else {
                    // `expr != true` → `!expr`
                    formatter.removeTokens(in: removalRange)
                    formatter.insert(.operator("!", .prefix), at: expressionStart)
                }
            } else { // boolValue == "false"
                if op == "==" {
                    // `expr == false` → `!expr`
                    formatter.removeTokens(in: removalRange)
                    formatter.insert(.operator("!", .prefix), at: expressionStart)
                } else {
                    // `expr != false` → `expr`
                    formatter.removeTokens(in: removalRange)
                }
            }
        }
    } examples: {
        """
        **Basic comparisons:**

        ```diff
        - if isEnabled == true { print("On") }
        + if isEnabled { print("On") }

        - if isDisabled == false { print("Off") }
        + if !isDisabled { print("Off") }

        - if isOnline != true { print("Offline") }
        + if !isOnline { print("Offline") }

        - if isReady != false { print("Ready") }
        + if isReady { print("Ready") }
        ```

        **Control flow statements:**

        ```diff
        - while running == true { doWork() }
        + while running { doWork() }

        - guard status == false else { return }
        + guard !status else { return }

        - for item in items where item.isValid == true { }
        + for item in items where item.isValid { }
        ```

        **Assignments and expressions:**

        ```diff
        - let isActive = userLoggedIn == true
        + let isActive = userLoggedIn

        - let isInactive = userLoggedIn == false  
        + let isInactive = !userLoggedIn

        - return isComplete == true
        + return isComplete

        - let status = isOnline == true ? "Online" : "Offline"
        + let status = isOnline ? "Online" : "Offline"
        ```

        **Property and method calls:**

        ```diff
        - if obj.property.isEnabled == true { }
        + if obj.property.isEnabled { }

        - if validator.check(input) == false { }
        + if !validator.check(input) { }

        - if MyClass.isFeatureEnabled == true { }
        + if MyClass.isFeatureEnabled { }
        ```

        **Multiple conditions:**

        ```diff
        - if isReady == true && isComplete == true { }
        + if isReady && isComplete { }

        - if isReady == false || isComplete == false { }
        + if !isReady || !isComplete { }
        ```

        **✅ Force unwrapped optionals ARE transformed (returns non-optional Bool):**

        ```diff
        - if optional! == true { }
        + if optional! { }

        - if optional! == false { }
        + if !optional! { }
        ```

        **❌ These cases are NOT modified (optional Bool expressions):**

        ```swift
        // Optional chaining - returns Bool?
        if user?.isActive == true { }
        if profile?.settings?.isPublic != false { }

        // Array/Dictionary access - returns Bool?
        if flags["enabled"] == true { }
        if boolArray[0] != false { }

        // Optional-returning properties/methods - returns Bool?
        if collection.last == true { }
        if collection.first != false { }
        if values.min() == true { }

        // Nil coalescing with optionals
        if (user?.isActive ?? false) == true { }
        ```
        """
    }
}
