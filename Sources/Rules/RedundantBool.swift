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
        help: "Rule to remove redundant boolean comparisons (`== true` → `value`, `== false` → `!value`, `!= true` → `!value`, `!= false` → `value`).",
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

            var expressionIndex = i
            while let before = formatter.index(before: expressionIndex, where: { !$0.isKeyword }) {
                let token = formatter.tokens[before]
                if token == .operator("?", .postfix) {
                    return // optional access detected, skip
                } else {
                    expressionIndex = before
                }
            }

            if let firstBeforeIdentifier = formatter.index(before: i, where: { $0.isSpaceOrComment }) {
                if value == "true" {
                    if op == "==" {
                        // Remove `== true`
                        formatter.removeTokens(in: firstBeforeIdentifier ... nextIndex)
                    } else {
                        // Replace `!= true` with `!value`
                        formatter.removeTokens(in: firstBeforeIdentifier ... nextIndex)
                        if let prevIndex = formatter.index(before: i, where: { !$0.isSpaceOrComment }) {
                            if let beforeExpressionIndex = formatter.index(before: prevIndex, where: { !$0.isOperator(".") && !$0.isIdentifier }) {
                                formatter.insert(.operator("!", .prefix), at: beforeExpressionIndex + 1)
                            } else {
                                formatter.insert(.operator("!", .prefix), at: prevIndex)
                            }
                        }
                    }
                } else if value == "false" {
                    if op == "==" {
                        // Replace `== false` with `!value`
                        formatter.removeTokens(in: firstBeforeIdentifier ... nextIndex)
                        if let prevIndex = formatter.index(before: i, where: { !$0.isSpaceOrComment }) {
                            if let beforeExpressionIndex = formatter.index(before: prevIndex, where: { !$0.isOperator(".") && !$0.isIdentifier }) {
                                formatter.insert(.operator("!", .prefix), at: beforeExpressionIndex + 1)
                            } else {
                                formatter.insert(.operator("!", .prefix), at: prevIndex)
                            }
                        }
                    } else {
                        // Remove `!= false`
                        formatter.removeTokens(in: firstBeforeIdentifier ... nextIndex)
                    }
                }
            }
        }
    } examples: {
        """
        ```diff
        - if isEnabled == true { print("On") }
        + if isEnabled { print("On") }

        - if isDisabled == false { print("Off") }
        + if !isDisabled { print("Off") }

        - if isOnline != true { print("Offline") }
        + if !isOnline { print("Offline") }

        - if isReady != false { print("Ready") }
        + if isReady { print("Ready") }

        - while running == true {}
        + while running {}

        - guard status == false else {}
        + guard !status else {}

        // ✅ These cases are NOT modified (optional Bool)
        - if formatter.token(at: closingBraceIndex - 1)?.isSpace == true {}
        - if formatter.token(at: nextIndex)?.isLinebreak != true {}

        ```
        """
    }
}
