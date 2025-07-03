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
        formatter.forEachToken { i, token in
            guard case let .operator(op, .infix) = token, op == "==" || op == "!=" else {
                return
            }

            // Check for Boolean after operator compare
            guard let nextIndex = formatter.index(after: i, where: { !$0.isSpaceOrComment }),
                  case let .identifier(value) = formatter.tokens[nextIndex],
                  value == "true" || value == "false"
            else {
                return
            }

            // Check if the expression before the operator is optional
            // This is a conservative approach - we skip transformation for any potentially optional expression
            var expressionStartIndex = i
            var foundOptionalPattern = false

            while let prevIndex = formatter.index(before: expressionStartIndex, where: { !$0.isSpaceOrComment }) {
                let prevToken = formatter.tokens[prevIndex]

                // Check for explicit optional operators
                if prevToken == .operator("?", .postfix) ||
                    prevToken == .operator("?", .infix) ||
                    prevToken == .operator("??", .infix)
                {
                    foundOptionalPattern = true
                    break
                }

                // Check for array/dictionary access patterns
                if prevToken == .endOfScope("]") {
                    foundOptionalPattern = true
                    break
                }

                // Check for known optional-returning property names
                if prevToken.isIdentifier, ["last", "first"].contains(prevToken.string) {
                    foundOptionalPattern = true
                    break
                }

                // Check for method calls that might return optionals
                if prevToken == .endOfScope(")") {
                    // Look for method name before the parentheses
                    if let methodStartIndex = formatter.index(of: .startOfScope("("), before: prevIndex),
                       let methodNameIndex = formatter.index(before: methodStartIndex, where: { $0.isIdentifier })
                    {
                        let methodName = formatter.tokens[methodNameIndex].string
                        if ["last", "first", "min", "max", "popLast", "popFirst"].contains(methodName) {
                            foundOptionalPattern = true
                            break
                        }
                    }
                }

                expressionStartIndex = prevIndex
            }

            if foundOptionalPattern {
                return // Optional detected, skip transformation
            }

            // Additional safety check: if the expression immediately before the operator
            // doesn't look like a simple non-optional identifier or property access, skip it
            if let beforeOperatorIndex = formatter.index(before: i, where: { !$0.isSpaceOrComment }) {
                let beforeToken = formatter.tokens[beforeOperatorIndex]

                // Only transform simple cases: identifiers or simple property access
                if !beforeToken.isIdentifier, beforeToken != .endOfScope(")") {
                    return // Skip complex expressions
                }

                // For method calls, skip only methods known to return optionals
                if beforeToken == .endOfScope(")") {
                    if let methodStartIndex = formatter.index(of: .startOfScope("("), before: beforeOperatorIndex),
                       let methodNameIndex = formatter.index(before: methodStartIndex, where: { $0.isIdentifier })
                    {
                        let methodName = formatter.tokens[methodNameIndex].string
                        // Blacklist of known optional-returning methods
                        let optionalReturningMethods = ["last", "first", "min", "max", "popLast", "popFirst"]
                        if optionalReturningMethods.contains(methodName) {
                            return // Known optional-returning method, skip
                        }
                    }
                    // Allow all other method calls
                }
            }

            // Find the start of the expression (for negation placement)
            var expressionStart = i
            while let prevIndex = formatter.index(before: expressionStart, where: { !$0.isSpaceOrComment }) {
                let prevToken = formatter.tokens[prevIndex]
                if prevToken.isIdentifier || prevToken == .operator(".", .infix) || prevToken == .endOfScope(")") {
                    expressionStart = prevIndex
                } else {
                    break
                }
            }

            // The removal range should include spaces around the operator and the boolean value
            // Find the first space/comment after the comparison expression
            var removeStartIndex = i + 1
            while removeStartIndex < formatter.tokens.count,
                  formatter.tokens[removeStartIndex].isSpaceOrComment
            {
                removeStartIndex += 1
            }

            // Move back to include any space before the operator
            if let spaceBeforeOp = formatter.index(before: i, where: { $0.isSpaceOrComment }) {
                removeStartIndex = spaceBeforeOp
            }

            if value == "true" {
                if op == "==" {
                    // Remove ` == true`
                    formatter.removeTokens(in: removeStartIndex ... nextIndex)
                } else {
                    // Replace `!= true` with `!expression`
                    formatter.removeTokens(in: removeStartIndex ... nextIndex)
                    formatter.insert(.operator("!", .prefix), at: expressionStart)
                }
            } else if value == "false" {
                if op == "==" {
                    // Replace `== false` with `!expression`
                    formatter.removeTokens(in: removeStartIndex ... nextIndex)
                    formatter.insert(.operator("!", .prefix), at: expressionStart)
                } else {
                    // Remove `!= false`
                    formatter.removeTokens(in: removeStartIndex ... nextIndex)
                }
            }
        }
    } examples: {
        """
        ```**Basic comparisons:**

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
