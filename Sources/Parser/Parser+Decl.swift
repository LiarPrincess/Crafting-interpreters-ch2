// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

extension Parser {

  func declaration() -> Stmt? {
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

  func varDeclaration() throws -> Stmt {
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
}
