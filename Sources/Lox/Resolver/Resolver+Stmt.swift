// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

extension Resolver {

  func visitPrintStmt(_ stmt: PrintStmt) throws {
    try self.resolve(stmt.expr)
  }

  func visitExpressionStmt(_ stmt: ExpressionStmt) throws {
    try self.resolve(stmt.expr)
  }

  func visitBlockStmt(_ stmt: BlockStmt) throws {
    self.beginScope()
    try self.resolve(stmt.statements)
    self.endScope()
  }

  func visitIfStmt(_ stmt: IfStmt) throws {
    try self.resolve(stmt.condition)
    try self.resolve(stmt.thenBranch)
    if let elseBranch = stmt.elseBranch {
      try self.resolve(elseBranch)
    }
  }

  func visitWhileStmt(_ stmt: WhileStmt) throws {
    try self.resolve(stmt.condition)
    try self.resolve(stmt.body)
  }

  func visitReturnStmt(_ stmt: ReturnStmt) throws {
    guard self.currentFunction != .none else {
      throw ResolverError.topLevelReturn
    }

    if let value = stmt.value {
      try self.resolve(value)
    }
  }
}
