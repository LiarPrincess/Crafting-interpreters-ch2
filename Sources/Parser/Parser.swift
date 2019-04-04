// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

protocol ParserType {
  func parse() -> [Stmt]?
}

class Parser: ParserType {
  private let tokens: [Token]
  private var current = 0

  init(_ tokens: [Token]) {
    self.tokens = tokens
  }

  func parse() -> [Stmt]? {
    var statements = [Stmt]()
    while !self.isAtEnd {
      if let statement = self.declaration() {
        statements.append(statement)
      }
    }
    return statements
  }

  // MARK: - Traversal

  /// Have we arrived at the last token?
  var isAtEnd: Bool {
    return self.peek.type == TokenType.eof
  }

  /// Return current token and advance to the next one
  @discardableResult
  func advance() -> Token {
    let current = self.peek

    if !self.isAtEnd {
      self.current += 1
    }

    return current
  }

  /// Current token
  var peek: Token {
    return self.tokens[self.current]
  }

  /// Previous token
  var previous: Token {
    return self.tokens[self.current - 1]
  }

  /// Check if current token is @param
  func check(_ type: TokenType) -> Bool {
    if self.isAtEnd {
      return false
    }

    return self.peek.type == type
  }

  /// Consume if current token is @param otherwise throw error
  func consumeOrThrow(type: TokenType, error: ParseError) throws {
    if self.check(type) {
      self.advance()
      return
    }

    throw self.error(token: self.peek, error: error)
  }

  /// Consume if current token is in @param
  func match(_ types: TokenType...) -> Bool {
    for type in types {
      if self.check(type) {
        self.advance()
        return true
      }
    }

    return false
  }

  // MARK: - Operators

  func toOperator(_ tokenType: TokenType) -> Operator {
    let op = Operator.fromToken(tokenType)
    assert(op != nil, "\(self.previous.type) cannot be converted to operator")
    return op!
  }

  // MARK: - Errors

  func synchronize() {
    self.advance()

    while !self.isAtEnd {
      if self.previous.type == .semicolon {
        return
      }

      switch self.peek.type {
      case .class, .fun, .var, .for, .if, .while, .print, .return: return
      default: self.advance()
      }
    }
  }

  func error(token: Token, error: ParseError) -> ParseError {
    Lox.error(location: SourceLocation.tmp, message: error.description)
    return error
  }
}
