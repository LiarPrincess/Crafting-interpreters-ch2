// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

enum ParseError: Error, CustomStringConvertible {
  case missingSemicolon
  case missingRightParen
  case missingVariableName
  case expectedExpression

  var description: String {
    switch self {
    case .missingSemicolon: return "Expected ';' after statement."
    case .missingRightParen: return "Expected ')' after expression."
    case .missingVariableName: return "Expected variable name."
    case .expectedExpression: return "Expected expression."
    }
  }
}

class Parser {
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

  // MARK: - Statements

  private func declaration() -> Stmt? {
    do {
      if self.match(.var) {
        return try self.varDeclaration()
      }

      return try self.statement()
    }
    catch {
      self.synchronize()
      return nil
    }
  }

  private func varDeclaration() throws -> Stmt {
    let current = self.peek

    guard case let TokenType.identifier(name) = current.type else {
      throw ParseError.missingVariableName
    }
    self.advance()

    var expr: Expr?
    if self.match(.equal) {
      expr = try self.expression()
    }

    try self.consumeOrThrow(type: .semicolon, error: .missingSemicolon)
    return VarStmt(name: name, initializer: expr)
  }

  private func statement() throws -> Stmt {
    if self.match(.print) {
      return try self.printStatement()
    }

    return try self.expressionStatement()
  }

  private func printStatement() throws -> Stmt {
    let expr = try self.expression()
    try self.consumeOrThrow(type: .semicolon, error: .missingSemicolon)
    return PrintStmt(expr: expr)
  }

  private func expressionStatement() throws -> Stmt {
    let expr = try self.expression()
    try self.consumeOrThrow(type: .semicolon, error: .missingSemicolon)
    return ExpressionStmt(expr: expr)
  }

  // MARK: - Expressions

  private func expression() throws -> Expr {
    return try self.equality()
  }

  private func equality() throws -> Expr {
    var expr = try self.comparison()

    while self.match(.bangEqual, .equalEqual) {
      let op = self.previous
      let right = try self.comparison()
      expr = BinaryExpr(op: op, left: expr, right: right)
    }
    return expr;
  }

  private func comparison() throws -> Expr {
    var expr = try self.addition()

    while self.match(.greater, .greaterEqual, .less, .lessEqual) {
      let op = self.previous
      let right = try self.addition()
      expr = BinaryExpr(op: op, left: expr, right: right)
    }
    return expr;
  }

  private func addition() throws -> Expr{
    var expr = try self.multiplication()

    while self.match(.minus, .plus) {
      let op = self.previous
      let right = try self.multiplication()
      expr = BinaryExpr(op: op, left: expr, right: right)
    }
    return expr;
  }

  private func multiplication() throws -> Expr{
    var expr = try self.unary()

    while self.match(.slash, .star) {
      let op = self.previous
      let right = try self.unary()
      expr = BinaryExpr(op: op, left: expr, right: right)
    }
    return expr;
  }

  private func unary() throws -> Expr {
    if self.match(.bang, .minus) {
      let op = self.previous
      let right = try self.unary()
      return UnaryExpr(op: op, right: right)
    }
    return try self.primary()
  }

  private func primary() throws -> Expr {
    if self.match(.false) { return BoolExpr(value: false) }
    if self.match(.true) { return BoolExpr(value: true) }
    if self.match(.nil) { return NilExpr() }

    let current = self.peek

    if case let TokenType.number(value) = current.type {
      self.advance()
      return NumberExpr(value: value)
    }

    if case let TokenType.string(value) = current.type {
      self.advance()
      return StringExpr(value: value)
    }

    if case let TokenType.identifier(name) = current.type {
      self.advance()
      return VariableExpr(name: name)
    }

    if self.match(.leftParen) {
      let expr = try self.expression()
      try self.consumeOrThrow(type: .rightParen, error: .missingRightParen)
      return GroupingExpr(expr: expr)
    }

    throw self.error(token: current, error: .expectedExpression)
  }

  // MARK: - Traversal

  /// Have we arrived at the last token?
  private var isAtEnd: Bool {
    return self.peek.type == TokenType.eof
  }

  /// Return current token and advance to the next one
  @discardableResult
  private func advance() -> Token {
    let current = self.peek

    if !self.isAtEnd {
      self.current += 1
    }

    return current
  }

  /// Current token
  private var peek: Token {
    return self.tokens[self.current]
  }

  /// Previous token
  private var previous: Token {
    return self.tokens[self.current - 1]
  }

  /// Check if current token is @param
  private func check(_ type: TokenType) -> Bool {
    if self.isAtEnd {
      return false
    }

    return self.peek.type == type
  }

  /// Consume if current token is @param otherwise throw error
  private func consumeOrThrow(type: TokenType, error: ParseError) throws {
    if self.check(type) {
      self.advance()
      return
    }

    throw self.error(token: self.peek, error: error)
  }

  /// Consume if current token is in @param
  private func match(_ types: TokenType...) -> Bool {
    for type in types {
      if self.check(type) {
        self.advance()
        return true
      }
    }

    return false
  }

  // MARK: - Errors

  private func synchronize() {
    self.advance()

    while !self.isAtEnd {
      if self.previous.type == .semicolon {
        return
      }

      switch (self.peek.type) {
      case .class, .fun, .var, .for, .if, .while, .print, .return: return
      default: self.advance()
      }
    }
  }

  private func error(token: Token, error: ParseError) -> ParseError {
    Lox.error(location: token.location, message: error.description)
    return error
  }
}
