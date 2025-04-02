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
            guard case let .operator(op, .infix) = token, op == "==" || op == "!=" else { return }

            guard let prevIndex = formatter.index(before: i, where: { !$0.isSpaceOrComment }),
                  let nextIndex = formatter.index(after: i, where: { !$0.isSpaceOrComment }),
                  case .identifier = formatter.tokens[prevIndex],
                  case let .identifier(value) = formatter.tokens[nextIndex],
                  value == "true" || value == "false"
            else {
                return
            }

            if let firstAfterIdentifier = formatter.index(before: i, where: { $0.isSpaceOrComment }) {
                if op == "==" {
                    if value == "true" {
                        formatter.removeTokens(in: firstAfterIdentifier ... nextIndex)
                    } else { // value == "false"
                        formatter.removeTokens(in: firstAfterIdentifier ... nextIndex)
                        formatter.insert(.operator("!", .prefix), at: prevIndex)
                    }
                } else if op == "!=" {
                    if value == "true" {
                        formatter.removeTokens(in: firstAfterIdentifier ... nextIndex)
                        formatter.insert(.operator("!", .prefix), at: prevIndex)
                    } else { // value == "false"
                        formatter.removeTokens(in: firstAfterIdentifier ... nextIndex)
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

        - if status != true { print("Inactive") }
        + if !status { print("Inactive") }

        - if status != false { print("Active") }
        + if status { print("Active") }
        ```
        """
    }
}
