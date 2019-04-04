// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

extension Parser {

  func declaration() -> Stmt? {
    do {
      if self.match(.var) {
        return try self.varDeclaration()
      }

      if self.match(.fun) {
        return try self.functionDeclaration(kind: "function")
      }

      return try self.statement()
    }
    catch {
      self.synchronize()
      return nil
    }
  }

  func varDeclaration() throws -> Stmt {
    let name = try self.consumeIdentifierOrThrow()

    var expr: Expr?
    if self.match(.equal) {
      expr = try self.expression()
    }

    try self.consumeOrThrow(type: .semicolon, error: .missingToken("';'"))
    return VarStmt(name: name, initializer: expr)
  }

  func functionDeclaration(kind: String) throws -> Stmt {
    let name = try self.consumeIdentifierOrThrow()

    var parameters = [String]()
    try self.consumeOrThrow(type: .leftParen, error: .missingToken("'('"))
    if !self.check(.rightParen) {
      repeat {
        if parameters.count >= self.maxArgCount {
          self.error(token: self.peek, error: .tooManyArguments)
        }

        parameters.append(try self.consumeIdentifierOrThrow())
      } while self.match(.comma)
    }
    try self.consumeOrThrow(type: .rightParen, error: .missingToken("')'"))

    try self.consumeOrThrow(type: .leftBrace, error: .missingToken("'{'"))
    let body = try self.blockStatement()

    return FunctionStmt(name: name, parameters: parameters, body: body)
  }

  /// Consume current token if it is identifier otherwise throw .expectedIdentifier
  private func consumeIdentifierOrThrow() throws -> String {
    if case let TokenType.identifier(name) = self.peek.type {
      self.advance()
      return name
    }

    throw self.error(token: self.peek, error: .expectedIdentifier)
  }
}
