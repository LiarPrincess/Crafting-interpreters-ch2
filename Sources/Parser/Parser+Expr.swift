// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

extension Parser {

  func expression() throws -> Expr {
    return try self.assignment()
  }

  func assignment() throws -> Expr {
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

  func or() throws -> Expr {
    var expr = try self.and()

    while self.match(.or) {
      let right = try self.and()
      expr = LogicalExpr(op: .or, left: expr, right: right)
    }
    return expr
  }

  func and() throws -> Expr {
    var expr = try self.equality()

    while self.match(.and) {
      let right = try self.equality()
      expr = LogicalExpr(op: .and, left: expr, right: right)
    }
    return expr
  }

  func equality() throws -> Expr {
    var expr = try self.comparison()

    while self.match(.bangEqual, .equalEqual) {
      let op = self.toOperator(self.previous.type)
      let right = try self.comparison()
      expr = BinaryExpr(op: op, left: expr, right: right)
    }
    return expr
  }

  func comparison() throws -> Expr {
    var expr = try self.addition()

    while self.match(.greater, .greaterEqual, .less, .lessEqual) {
      let op = self.toOperator(self.previous.type)
      let right = try self.addition()
      expr = BinaryExpr(op: op, left: expr, right: right)
    }
    return expr
  }

  func addition() throws -> Expr{
    var expr = try self.multiplication()

    while self.match(.minus, .plus) {
      let op = self.toOperator(self.previous.type)
      let right = try self.multiplication()
      expr = BinaryExpr(op: op, left: expr, right: right)
    }
    return expr
  }

  func multiplication() throws -> Expr{
    var expr = try self.unary()

    while self.match(.slash, .star) {
      let op = self.toOperator(self.previous.type)
      let right = try self.unary()
      expr = BinaryExpr(op: op, left: expr, right: right)
    }
    return expr
  }

  func unary() throws -> Expr {
    if self.match(.bang, .minus) {
      let op = self.toOperator(self.previous.type)
      let right = try self.unary()
      return UnaryExpr(op: op, right: right)
    }
    return try self.primary()
  }

  func primary() throws -> Expr {
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
}
