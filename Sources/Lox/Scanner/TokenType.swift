// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

enum TokenType {

  // Single-character tokens
  case leftParen, rightParen
  case leftBrace, rightBrace
  case comma, dot
  case minus, plus
  case semicolon
  case slash
  case star

  // One or two character tokens
  case bang, bangEqual
  case equal, equalEqual
  case less, lessEqual
  case greater, greaterEqual

  // Literals
  case identifier(String)
  case string(String)
  case number(Double)

  // Keywords
  case and
  case `class`
  case `else`
  case `false`
  case fun
  case `for`
  case `if`
  case `nil`
  case or
  case print
  case `return`
  case `super`
  case this
  case `true`
  case `var`
  case `while`

  case eof
}

// MARK: - Equatable

extension TokenType: Equatable {

  // swiftlint:disable:next cyclomatic_complexity function_body_length
  static func == (lhs: TokenType, rhs: TokenType) -> Bool {
    switch (lhs, rhs) {

    // Single-character tokens
    case (.leftParen, .leftParen): return true
    case (.rightParen, .rightParen): return true
    case (.leftBrace, .leftBrace): return true
    case (.rightBrace, .rightBrace): return true
    case (.comma, .comma): return true
    case (.dot, .dot): return true
    case (.minus, .minus): return true
    case (.plus, .plus): return true
    case (.semicolon, .semicolon): return true
    case (.slash, .slash): return true
    case (.star, .star): return true

    // One or two character tokens
    case (.bang, .bang): return true
    case (.bangEqual, .bangEqual): return true
    case (.equal, .equal): return true
    case (.equalEqual, .equalEqual): return true
    case (.greater, .greater): return true
    case (.greaterEqual, .greaterEqual): return true
    case (.less, .less): return true
    case (.lessEqual, .lessEqual): return true

    // Literals
    case let (.identifier(l), .identifier(r)): return l == r
    case let (.string(l), .string(r)): return l == r
    case let (.number(l), .number(r)): return l == r

    // Keywords
    case (.and, .and): return true
    case (.class, .class): return true
    case (.else, .else): return true
    case (.false, .false): return true
    case (.fun, .fun): return true
    case (.for, .for): return true
    case (.if, .if): return true
    case (.nil, .nil): return true
    case (.or, .or): return true
    case (.print, .print): return true
    case (.return, .return): return true
    case (.super, .super): return true
    case (.this, .this): return true
    case (.true, .true): return true
    case (.var, .var): return true
    case (.while, .while): return true

    case (.eof, .eof): return true

    default:
      return false
    }
  }
}

// MARK: - CustomStringConvertible

extension TokenType: CustomStringConvertible {
  var description: String {
    switch self {
    // Single-character tokens
    case .leftParen: return "("
    case .rightParen: return ")"
    case .leftBrace: return "{"
    case .rightBrace: return "}"
    case .comma: return ","
    case .dot: return "."
    case .minus: return "-"
    case .plus: return "+"
    case .semicolon: return ";"
    case .slash: return "/"
    case .star: return "*"

    // One or two character tokens
    case .bang: return "!"
    case .bangEqual: return "!="
    case .equal: return "="
    case .equalEqual: return "=="
    case .greater: return ">"
    case .greaterEqual: return ">="
    case .less: return "<"
    case .lessEqual: return "<="

    // Literals
    case let .identifier(value): return "@\(value)"
    case let .string(value): return "\"\(value)\""
    case let .number(value): return String(describing: value)

    // Keywords
    case .and: return "and"
    case .class: return "class"
    case .else: return "else"
    case .false: return "false"
    case .fun: return "fun"
    case .for: return "for"
    case .if: return "if"
    case .nil: return "nil"
    case .or: return "or"
    case .print: return "print"
    case .return: return "return"
    case .super: return "super"
    case .this: return "this"
    case .true: return "true"
    case .var: return "var"
    case .while: return "while"

    case .eof: return "eof"
    }
  }
}
