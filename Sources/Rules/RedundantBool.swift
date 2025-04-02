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
        help: "Remove `== true` and replace `== false` with `!value`.",
        options: [],
        sharedOptions: []
    ) { formatter in
        formatter.forEachToken { i, token in
            guard case .operator("==", .infix) = token else { return }

            guard let prevIndex = formatter.index(before: i, where: { !$0.isSpaceOrComment }),
                  let nextIndex = formatter.index(after: i, where: { !$0.isSpaceOrComment }),
                  case .identifier = formatter.tokens[prevIndex],
                  case let .identifier(value) = formatter.tokens[nextIndex],
                  value == "true" || value == "false"
            else {
                return
            }

            // Find the first token before `==` that is not a space or comment
            if let firstAfterIdentifier = formatter.index(before: i, where: { $0.isSpaceOrComment }) {
                if value == "true" {
                    // Remove `== true`, leaving just the boolean variable
                    formatter.removeTokens(in: firstAfterIdentifier ... nextIndex)
                } else if value == "false" {
                    // Remove `== false`, leaving just the boolean variable
                    formatter.removeTokens(in: firstAfterIdentifier ... nextIndex)
                    // Insert `!` operator before the boolean variable to negate it
                    formatter.insert(.operator("!", .prefix), at: prevIndex)
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

        - while running == true {}
        + while running {}

        - guard status == false else {}
        + guard !status else {}
        ```
        """
    }
}
