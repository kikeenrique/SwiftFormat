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
        Removes redundant comparisons with `true`/`false`, but only when the left-hand side is provably a non-optional `Bool`:

        - A parenthesized boolean expression, e.g. `(a && b) == true` → `(a && b)`
        - A `!`-negated expression, e.g. `!isReady == false` → `isReady`
        - A name resolvable in the same file to a non-optional `Bool` — a local `let`/`var`, a function parameter, a `self` property, or a same-file method returning `Bool`.

        Anything whose type can't be resolved locally (members of other types, values from other files, complex inference) is left unchanged, since removing the comparison could fail to compile if the value is actually optional.

        This rule is the inverse of `preferExplicitFalse` and is mutually exclusive with it — enable only one.
        """,
        disabledByDefault: true
    ) { formatter in
        formatter.forEach(.operator("==", .infix)) { i, _ in
            formatter.removeRedundantBoolComparison(at: i, isEqualityCheck: true)
        }
        formatter.forEach(.operator("!=", .infix)) { i, _ in
            formatter.removeRedundantBoolComparison(at: i, isEqualityCheck: false)
        }
    } examples: {
        """
        ```diff
        - if (a && b) == true {
        + if (a && b) {

        - if !isReady == false {
        + if isReady {
        ```

        ```diff
          func handle(isEnabled: Bool) {
        -     if isEnabled == true {
        +     if isEnabled {
          }
        ```

        These are **not** modified, because the left-hand side can't be proven to
        be a non-optional `Bool` from the current file:

        ```swift
        if otherObject.isActive == true {}  // member of another type
        if importedValue == true {}         // declared in another file
        if value! == true {}                // force-unwrap
        if dict[key] == true {}             // subscript
        if user?.isActive == true {}        // optional
        ```
        """
    }
}

// MARK: - Helpers

extension Formatter {
    /// Operators whose result is always a (non-optional) `Bool`.
    static let boolResultOperators: Set<String> = [
        "==", "!=", "===", "!==", "~=", "<", ">", "<=", ">=", "&&", "||",
    ]

    /// Removes a redundant `== true` / `== false` / `!= true` / `!= false`
    /// comparison at `operatorIndex`, inserting a `!` negation where needed.
    func removeRedundantBoolComparison(at operatorIndex: Int, isEqualityCheck: Bool) {
        // The right side must be a `true` or `false` literal (a backticked
        // `` `true` `` identifier has a different string and is ignored here).
        guard let boolIndex = index(after: operatorIndex, where: { !$0.isSpaceOrCommentOrLinebreak }),
              case let .identifier(boolValue) = tokens[boolIndex],
              boolValue == "true" || boolValue == "false"
        else {
            return
        }

        // Only transform when the left side is provably a non-optional Bool.
        guard isProvableBoolExpression(before: operatorIndex) else {
            return
        }

        // `== true` / `!= false` simply drop the comparison; `== false` / `!= true`
        // require negating the operand.
        let shouldNegate = (boolValue == "false") == isEqualityCheck

        // Don't remove comments that sit between the operand and the literal.
        let removalRange = boolComparisonRemovalRange(from: operatorIndex, to: boolIndex)
        guard !tokens[removalRange].contains(where: \.isComment) else {
            return
        }

        guard shouldNegate else {
            removeTokens(in: removalRange)
            return
        }

        // If the operand already has a leading prefix `!`, collapse it instead of
        // inserting a second one (avoids `!!`).
        let expressionStart = boolExpressionStart(before: operatorIndex)
        let existingNegation = index(before: expressionStart, where: { !$0.isSpaceOrCommentOrLinebreak })
            .flatMap { tokens[$0] == .operator("!", .prefix) ? $0 : nil }

        removeTokens(in: removalRange)
        if let existingNegation {
            removeToken(at: existingNegation)
        } else {
            insert(.operator("!", .prefix), at: expressionStart)
        }
    }

    /// Whether the operand ending just before `index` is provably a non-optional
    /// `Bool`: a `!`-negation, a parenthesized boolean expression, or a name that
    /// resolves in the same file to a non-optional `Bool`.
    func isProvableBoolExpression(before index: Int) -> Bool {
        // 1. A `!`-prefixed operand is always Bool (the `!` operator requires Bool).
        let start = boolExpressionStart(before: index)
        if let beforeStart = self.index(before: start, where: { !$0.isSpaceOrCommentOrLinebreak }),
           tokens[beforeStart] == .operator("!", .prefix)
        {
            return true
        }

        // 2. A parenthesized boolean expression, e.g. `(a && b)` or `(x < y)`.
        if let closeParen = self.index(before: index, where: { !$0.isSpaceOrCommentOrLinebreak }),
           tokens[closeParen] == .endOfScope(")"),
           let openParen = indexOfOpeningParen(closing: closeParen),
           isGroupingParen(at: openParen),
           parenthesizedExpressionIsBool(from: openParen, to: closeParen)
        {
            return true
        }

        // 3. A name / call / `self` member resolvable to a non-optional Bool.
        return operandResolvesToBool(before: index)
    }

    /// The index of the `(` matching the `)` at `closeParen`.
    func indexOfOpeningParen(closing closeParen: Int) -> Int? {
        guard tokens[closeParen] == .endOfScope(")") else { return nil }
        var depth = 0
        var current = closeParen
        while let prev = index(before: current, where: { _ in true }) {
            switch tokens[prev] {
            case .endOfScope(")"):
                depth += 1
            case .startOfScope("("):
                if depth == 0 { return prev }
                depth -= 1
            default:
                break
            }
            current = prev
        }
        return nil
    }

    /// Whether the `(` at `index` starts a grouping expression rather than a
    /// call or subscript argument list.
    func isGroupingParen(at index: Int) -> Bool {
        guard let prevIndex = self.index(before: index, where: { !$0.isSpaceOrCommentOrLinebreak }) else {
            return true
        }
        let token = tokens[prevIndex]
        return !(token.isIdentifier
            || token == .endOfScope(")")
            || token == .endOfScope("]")
            || token == .operator("?", .postfix)
            || token == .operator("!", .postfix))
    }

    /// Whether the expression between `openParen` and `closeParen` has a
    /// top-level operator that yields a `Bool` (a comparison/logical operator,
    /// a `!` negation, or an `is` check).
    func parenthesizedExpressionIsBool(from openParen: Int, to closeParen: Int) -> Bool {
        var depth = 0
        var current = openParen
        while let next = index(after: current, where: { _ in true }), next < closeParen {
            let token = tokens[next]
            if token.isStartOfScope {
                depth += 1
            } else if token.isEndOfScope {
                depth -= 1
            } else if depth == 0 {
                if case let .operator(op, .infix) = token, Self.boolResultOperators.contains(op) {
                    return true
                }
                if token == .operator("!", .prefix) || token == .keyword("is") {
                    return true
                }
            }
            current = next
        }
        return false
    }

    /// Finds the start of the operand before `index`, so a `!` negation can be
    /// placed in front of the whole expression.
    func boolExpressionStart(before index: Int) -> Int {
        var startIndex = index

        while let prevIndex = self.index(before: startIndex, where: { !$0.isSpaceOrCommentOrLinebreak }) {
            let token = tokens[prevIndex]

            guard token.isIdentifier ||
                token == .operator(".", .infix) ||
                token == .endOfScope(")") ||
                token == .operator("!", .postfix)
            else {
                break
            }

            startIndex = prevIndex

            // Jump over a parenthesized group to its matching opening paren.
            if token == .endOfScope(")"), let openParen = indexOfOpeningParen(closing: prevIndex) {
                startIndex = openParen
            }
        }

        return startIndex
    }

    /// The range to remove for a comparison: the operator, the boolean literal,
    /// and any whitespace immediately before the operator.
    func boolComparisonRemovalRange(from operatorIndex: Int, to boolIndex: Int) -> ClosedRange<Int> {
        var startIndex = operatorIndex

        while let prevIndex = index(before: startIndex, where: { _ in true }),
              tokens[prevIndex].isSpaceOrCommentOrLinebreak
        {
            startIndex = prevIndex
        }

        return startIndex ... boolIndex
    }

    // MARK: Local type resolution

    /// Whether the operand ending just before `operatorIndex` is a simple name,
    /// `self` property, or function call that resolves in the same file to a
    /// non-optional `Bool`.
    func operandResolvesToBool(before operatorIndex: Int) -> Bool {
        guard let operandEnd = index(before: operatorIndex, where: { !$0.isSpaceOrCommentOrLinebreak }) else {
            return false
        }

        // Call: `name(...)` or `self.name(...)`.
        if tokens[operandEnd] == .endOfScope(")") {
            guard let openParen = indexOfOpeningParen(closing: operandEnd),
                  let nameIndex = index(before: openParen, where: { !$0.isSpaceOrCommentOrLinebreak }),
                  tokens[nameIndex].isIdentifier
            else {
                return false
            }
            let name = tokens[nameIndex].string
            switch qualifier(before: nameIndex) {
            case .none, .selfMember:
                return enclosingTypeFunctionReturnsBool(name, at: operatorIndex)
                    && !hasLocalBinding(of: name, at: operatorIndex)
            case .other:
                return false
            }
        }

        // Identifier: `name` or `self.name`.
        guard tokens[operandEnd].isIdentifier else { return false }
        let name = tokens[operandEnd].string
        switch qualifier(before: operandEnd) {
        case .none:
            return bareNameResolvesToBool(name, at: operandEnd)
        case .selfMember:
            return enclosingTypePropertyIsBool(name, at: operatorIndex)
        case .other:
            return false
        }
    }

    enum OperandQualifier {
        /// No qualifier — a bare `name`.
        case none
        /// `self.name`.
        case selfMember
        /// `obj.name`, `a.b.name`, etc. — not locally resolvable.
        case other
    }

    /// Classifies what precedes the identifier at `nameIndex`.
    func qualifier(before nameIndex: Int) -> OperandQualifier {
        guard let dotIndex = index(before: nameIndex, where: { !$0.isSpaceOrCommentOrLinebreak }),
              tokens[dotIndex] == .operator(".", .infix)
        else {
            return .none
        }
        guard let baseIndex = index(before: dotIndex, where: { !$0.isSpaceOrCommentOrLinebreak }),
              tokens[baseIndex] == .identifier("self"),
              // `self` must itself be unqualified (not `foo.self`).
              index(before: baseIndex, where: { !$0.isSpaceOrCommentOrLinebreak })
              .map({ tokens[$0] != .operator(".", .infix) }) ?? true
        else {
            return .other
        }
        return .selfMember
    }

    /// Whether the type is written as exactly `Bool` (non-optional).
    func isExactlyBool(_ type: TypeName?) -> Bool {
        guard let type, !type.isOptionalType else { return false }
        return type.withoutParens().string == "Bool"
    }

    /// Whether the property at `introducerIndex` (a `let`/`var`) is a
    /// non-optional `Bool` — by annotation, or by a `true`/`false` initializer.
    func propertyIsBool(atIntroducerIndex introducerIndex: Int) -> Bool {
        guard let property = parsePropertyDeclaration(atIntroducerIndex: introducerIndex) else {
            return false
        }
        if let type = property.type {
            return isExactlyBool(type)
        }
        if let value = property.value {
            return isBoolLiteral(in: value.expressionRange)
        }
        return false
    }

    /// Whether `range` contains exactly a single `true`/`false` literal.
    func isBoolLiteral(in range: ClosedRange<Int>) -> Bool {
        guard let first = index(of: .nonSpaceOrCommentOrLinebreak, in: Range(range)),
              let last = index(of: .nonSpaceOrCommentOrLinebreak, before: range.upperBound + 1),
              first == last,
              case let .identifier(value) = tokens[first],
              value == "true" || value == "false"
        else {
            return false
        }
        return true
    }

    /// Whether a property named `name` of the enclosing type is a non-optional
    /// `Bool` (and every same-named property is, if there are several).
    func enclosingTypePropertyIsBool(_ name: String, at index: Int) -> Bool {
        guard let type = parseEnclosingType(containing: index) else { return false }
        let properties = type.body.filter { ($0.keyword == "let" || $0.keyword == "var") && $0.name == name }
        guard !properties.isEmpty else { return false }
        return properties.allSatisfy { propertyIsBool(atIntroducerIndex: $0.keywordIndex) }
    }

    /// Whether every same-named method of the enclosing type returns `Bool`.
    func enclosingTypeFunctionReturnsBool(_ name: String, at index: Int) -> Bool {
        guard let type = parseEnclosingType(containing: index) else { return false }
        let functions = type.body.filter { $0.keyword == "func" && $0.name == name }
        guard !functions.isEmpty else { return false }
        return functions.allSatisfy {
            guard let function = parseFunctionDeclaration(keywordIndex: $0.keywordIndex) else { return false }
            return isExactlyBool(function.returnType)
        }
    }

    /// Resolves a bare identifier `name` to a non-optional `Bool`. Considers
    /// function parameters and local `let`/`var` bindings; if any binding of
    /// `name` can't be proven to be exactly `Bool`, returns `false` (skip).
    /// With no local binding, resolves `name` as a property of the enclosing type.
    func bareNameResolvesToBool(_ name: String, at useIndex: Int) -> Bool {
        let functions = enclosingFunctions(at: useIndex)
        var foundBoolBinding = false

        for function in functions {
            for argument in function.arguments where argument.internalLabel == name {
                if isExactlyBool(argument.type) { foundBoolBinding = true } else { return false }
            }
        }

        // Scan the outermost enclosing function body (which contains all nested
        // scopes) for any binding of `name`. Conservatively bail on any binding
        // that isn't a plainly-typed `Bool`.
        if let body = functions.last?.bodyRange {
            for i in body {
                switch tokens[i] {
                case .keyword("let"), .keyword("var"):
                    if namesInDeclaration(at: i)?.contains(name) == true {
                        if parsePropertyDeclaration(atIntroducerIndex: i)?.identifier == name,
                           propertyIsBool(atIntroducerIndex: i)
                        {
                            foundBoolBinding = true
                        } else {
                            return false
                        }
                    }
                case .keyword("for"):
                    if forLoopBinds(name, at: i) { return false }
                case .startOfScope("{"):
                    if isStartOfClosureOrFunctionBody(at: i), closureBinds(name, scopeStart: i) {
                        return false
                    }
                default:
                    break
                }
            }
        }

        if foundBoolBinding { return true }
        return enclosingTypePropertyIsBool(name, at: useIndex)
    }

    /// Whether `name` has any local binding (parameter, `let`/`var`, `for`, or
    /// closure parameter) in the enclosing function — used to detect that a bare
    /// call would actually be a local closure, not a method.
    func hasLocalBinding(of name: String, at useIndex: Int) -> Bool {
        let functions = enclosingFunctions(at: useIndex)
        for function in functions where function.arguments.contains(where: { $0.internalLabel == name }) {
            return true
        }
        guard let body = functions.last?.bodyRange else { return false }
        for i in body {
            switch tokens[i] {
            case .keyword("let"), .keyword("var"):
                if namesInDeclaration(at: i)?.contains(name) == true { return true }
            case .keyword("for"):
                if forLoopBinds(name, at: i) { return true }
            case .startOfScope("{"):
                if isStartOfClosureOrFunctionBody(at: i), closureBinds(name, scopeStart: i) { return true }
            default:
                break
            }
        }
        return false
    }

    /// The enclosing function/initializer/subscript declarations of `index`,
    /// innermost first.
    func enclosingFunctions(at index: Int) -> [FunctionDeclaration] {
        var result: [FunctionDeclaration] = []
        var current = index
        while let scopeStart = startOfScope(at: current) {
            if tokens[scopeStart] == .startOfScope("{"),
               let ownerIndex = indexOfLastSignificantKeyword(at: scopeStart, excluding: ["where"]),
               ["func", "init", "subscript"].contains(tokens[ownerIndex].string),
               let function = parseFunctionDeclaration(keywordIndex: ownerIndex),
               function.bodyRange?.lowerBound == scopeStart
            {
                result.append(function)
            }
            current = scopeStart
        }
        return result
    }

    /// Whether a `for` clause at `forIndex` binds `name` (between `for` and its
    /// `in` / body).
    func forLoopBinds(_ name: String, at forIndex: Int) -> Bool {
        var current = forIndex
        while let next = index(after: current, where: { _ in true }) {
            let token = tokens[next]
            if token == .keyword("in") || token == .startOfScope("{") { return false }
            if token == .identifier(name) { return true }
            current = next
        }
        return false
    }

    /// Whether the closure starting at `scopeStart` binds `name` in its
    /// parameter / capture list (before its `in`).
    func closureBinds(_ name: String, scopeStart: Int) -> Bool {
        var depth = 0
        var current = scopeStart
        while let next = index(after: current, where: { _ in true }) {
            let token = tokens[next]
            if token.isStartOfScope {
                depth += 1
            } else if token.isEndOfScope {
                if depth == 0 { return false }
                depth -= 1
            } else if depth == 0, token == .keyword("in") {
                return tokens[(scopeStart + 1) ..< next].contains(.identifier(name))
            }
            current = next
        }
        return false
    }
}
