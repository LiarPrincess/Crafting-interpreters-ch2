// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

// swiftlint:disable file_length

enum ParseError: Error, CustomStringConvertible {
  case missingToken(String)
  case expectedExpression
  case invalidAssignment

  var description: String {
    switch self {
    case let .missingToken(token): return "Expected \(token)."
    case .expectedExpression: return "Expected expression."
    case .invalidAssignment: return "Invalid assignment target."
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
      throw ParseError.missingToken("variable name")
    }
    self.advance()

    var expr: Expr?
    if self.match(.equal) {
      expr = try self.expression()
    }

    try self.consumeOrThrow(type: .semicolon, error: .missingToken("';'"))
    return VarStmt(name: name, initializer: expr)
  }

  private func statement() throws -> Stmt {
    if self.match(.print) {
      return try self.printStatement()
    }

    if self.match(.leftBrace) {
      return BlockStmt(statements: try self.blockStatement())
    }

    if self.match(.if) {
      return try self.ifStatement()
    }

    if self.match(.while) {
      return try self.whileStatement()
    }

    return try self.expressionStatement()
  }

  private func printStatement() throws -> Stmt {
    let expr = try self.expression()
    try self.consumeOrThrow(type: .semicolon, error: .missingToken(";"))
    return PrintStmt(expr: expr)
  }

  private func blockStatement() throws -> [Stmt] {
    var statements = [Stmt]()

    while !self.check(.rightBrace), !self.isAtEnd {
      if let declaration = self.declaration() {
        statements.append(declaration)
      }
    }

    try self.consumeOrThrow(type: .rightBrace, error: .missingToken("'}'"))
    return statements
  }

  private func ifStatement() throws -> Stmt {
    try self.consumeOrThrow(type: .leftParen, error: .missingToken("'('"))
    let condition = try self.expression()
    try self.consumeOrThrow(type: .rightParen, error: .missingToken("')'"))

    let thenBranch = try self.statement()

    var elseBranch: Stmt?
    if self.match(.else) {
      elseBranch = try self.statement()
    }

    return IfStmt(condition: condition, thenBranch: thenBranch, elseBranch: elseBranch)
  }

  private func whileStatement() throws -> Stmt {
    try self.consumeOrThrow(type: .leftParen, error: .missingToken("'('"))
    let condition = try self.expression()
    try self.consumeOrThrow(type: .rightParen, error: .missingToken("')'"))

    let body = try self.statement()
    return WhileStmt(condition: condition, body: body)
  }

  private func expressionStatement() throws -> Stmt {
    let expr = try self.expression()
    try self.consumeOrThrow(type: .semicolon, error: .missingToken("';'"))
    return ExpressionStmt(expr: expr)
  }

  // MARK: - Expressions

  private func expression() throws -> Expr {
    return try self.assignment()
  }

  private func assignment() throws -> Expr {
    let expr = try self.or()

    if self.match(.equal) {
      let equals = self.previous
      let value = try self.assignment()

      if let expr = expr as? VariableExpr {
        let name = expr.name
        return AssignExpr(name: name, value: value)
      }

      self.error(token: equals, error: .invalidAssignment)
    }

    return expr
  }

  private func or() throws -> Expr {
    var expr = try self.and()

    while self.match(.or) {
      let right = try self.and()
      expr = LogicalExpr(op: .or, left: expr, right: right)
    }
    return expr
  }

  private func and() throws -> Expr {
    var expr = try self.equality()

    while self.match(.and) {
      let right = try self.equality()
      expr = LogicalExpr(op: .and, left: expr, right: right)
    }
    return expr
  }

  private func equality() throws -> Expr {
    var expr = try self.comparison()

    while self.match(.bangEqual, .equalEqual) {
      let op = self.toOperator(self.previous.type)
      let right = try self.comparison()
      expr = BinaryExpr(op: op, left: expr, right: right)
    }
    return expr
  }

  private func comparison() throws -> Expr {
    var expr = try self.addition()

    while self.match(.greater, .greaterEqual, .less, .lessEqual) {
      let op = self.toOperator(self.previous.type)
      let right = try self.addition()
      expr = BinaryExpr(op: op, left: expr, right: right)
    }
    return expr
  }

  private func addition() throws -> Expr{
    var expr = try self.multiplication()

    while self.match(.minus, .plus) {
      let op = self.toOperator(self.previous.type)
      let right = try self.multiplication()
      expr = BinaryExpr(op: op, left: expr, right: right)
    }
    return expr
  }

  private func multiplication() throws -> Expr{
    var expr = try self.unary()

    while self.match(.slash, .star) {
      let op = self.toOperator(self.previous.type)
      let right = try self.unary()
      expr = BinaryExpr(op: op, left: expr, right: right)
    }
    return expr
  }

  private func unary() throws -> Expr {
    if self.match(.bang, .minus) {
      let op = self.toOperator(self.previous.type)
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
      try self.consumeOrThrow(type: .rightParen, error: .missingToken("')'"))
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

  // MARK: - Operators

  private func toOperator(_ tokenType: TokenType) -> Operator {
    let op = Operator.fromToken(tokenType)
    assert(op != nil, "Unable to map \(self.previous.type) to operator.")
    return op!
  }

  // MARK: - Errors

  private func synchronize() {
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

  private func error(token: Token, error: ParseError) -> ParseError {
    Lox.error(location: SourceLocation.tmp, message: error.description)
    return error
  }
}
