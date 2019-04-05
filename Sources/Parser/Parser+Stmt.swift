// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

extension Parser {

  func statement() throws -> Stmt {
    if self.match(.print) {
      return try self.printStatement()
    }

    if self.match(.leftBrace) {
      return BlockStmt(statements: try self.blockStatements())
    }

    if self.match(.if) {
      return try self.ifStatement()
    }

    if self.match(.while) {
      return try self.whileStatement()
    }

    if self.match(.for) {
      return try self.forStatement()
    }

    if self.match(.return) {
      return try self.returnStatement()
    }

    return try self.expressionStatement()
  }

  func printStatement() throws -> Stmt {
    let expr = try self.expression()
    try self.consumeOrThrow(type: .semicolon, error: .missingToken(";"))
    return PrintStmt(expr: expr)
  }

  func blockStatements() throws -> [Stmt] {
    var statements = [Stmt]()

    while !self.check(.rightBrace), !self.isAtEnd {
      if let declaration = self.declaration() {
        statements.append(declaration)
      }
    }

    try self.consumeOrThrow(type: .rightBrace, error: .missingToken("'}'"))
    return statements
  }

  func ifStatement() throws -> Stmt {
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

  func whileStatement() throws -> Stmt {
    try self.consumeOrThrow(type: .leftParen, error: .missingToken("'('"))
    let condition = try self.expression()
    try self.consumeOrThrow(type: .rightParen, error: .missingToken("')'"))

    let body = try self.statement()
    return WhileStmt(condition: condition, body: body)
  }

  func forStatement() throws -> Stmt {
    try self.consumeOrThrow(type: .leftParen, error: .missingToken("'('"))
    let initializer = try self.forStatementInitializer()
    let condition = try self.forStatementCondition()
    let increment = try self.forStatementIncrement()
    let body = try self.statement()

    //  {
    //    var i = 0;
    //    while (i < 10) {
    //      print i;
    //      i = i + 1;
    //    }
    //  }

    var result = body
    if let increment = increment {
      result = BlockStmt(statements: [result, ExpressionStmt(expr: increment)])
    }

    let whileCondition = condition ?? BoolExpr(value: true)
    result = WhileStmt(condition: whileCondition, body: result)

    if let initializer = initializer {
      result = BlockStmt(statements: [initializer, result])
    }

    return result
  }

  private func forStatementInitializer() throws -> Stmt? {
    if self.match(.semicolon) { return nil }
    if self.match(.var) { return try self.varDeclaration() }
    return try self.expressionStatement()
  }

  private func forStatementCondition() throws -> Expr? {
    if self.match(.semicolon) { return nil }
    let expr = try self.expression()
    try self.consumeOrThrow(type: .semicolon, error: .missingToken("';'"))
    return expr
  }

  private func forStatementIncrement() throws -> Expr? {
    if self.match(.rightParen) { return nil }
    let expr = try self.expression()
    try self.consumeOrThrow(type: .rightParen, error: .missingToken("')'"))
    return expr
  }

  private func expressionStatement() throws -> Stmt {
    let expr = try self.expression()
    try self.consumeOrThrow(type: .semicolon, error: .missingToken("';'"))
    return ExpressionStmt(expr: expr)
  }

  func returnStatement() throws -> Stmt {
    let result = self.check(.semicolon) ? nil : try self.expression()
    try self.consumeOrThrow(type: .semicolon, error: .missingToken("';'"))
    return ReturnStmt(value: result)
  }
}
