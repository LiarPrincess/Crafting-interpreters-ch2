// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

protocol StmtVisitor {
  associatedtype StmtResult

  @discardableResult
  func visitPrintStmt(_ stmt: PrintStmt) throws -> StmtResult
  @discardableResult
  func visitExpressionStmt(_ stmt: ExpressionStmt) throws -> StmtResult
  @discardableResult
  func visitVarStmt(_ stmt: VarStmt) throws -> StmtResult
  @discardableResult
  func visitBlockStmt(_ stmt: BlockStmt) throws -> StmtResult
  @discardableResult
  func visitIfStmt(_ stmt: IfStmt) throws -> StmtResult
  @discardableResult
  func visitWhileStmt(_ stmt: WhileStmt) throws -> StmtResult
  @discardableResult
  func visitFunctionStmt(_ stmt: FunctionStmt) throws -> StmtResult
  @discardableResult
  func visitReturnStmt(_ stmt: ReturnStmt) throws -> StmtResult
}

extension StmtVisitor {
  func visit(_ stmt: Stmt) throws -> StmtResult {
    switch stmt {
    case let stmt as PrintStmt:
      return try self.visitPrintStmt(stmt)
    case let stmt as ExpressionStmt:
      return try self.visitExpressionStmt(stmt)
    case let stmt as VarStmt:
      return try self.visitVarStmt(stmt)
    case let stmt as BlockStmt:
      return try self.visitBlockStmt(stmt)
    case let stmt as IfStmt:
      return try self.visitIfStmt(stmt)
    case let stmt as WhileStmt:
      return try self.visitWhileStmt(stmt)
    case let stmt as FunctionStmt:
      return try self.visitFunctionStmt(stmt)
    case let stmt as ReturnStmt:
      return try self.visitReturnStmt(stmt)
    default:
      fatalError("Unknown stmt \(stmt)")
    }
  }
}

class Stmt: Equatable, Hashable {

  func accept<V: StmtVisitor, R>(_ visitor: V) throws -> R where R == V.StmtResult {
    fatalError("Accept metod should be overriden in subclass")
  }

  static func == (lhs: Stmt, rhs: Stmt) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
  }
  func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self).hashValue)
  }
}

class PrintStmt: Stmt {
  let expr: Expr

  init(expr: Expr) {
    self.expr = expr
  }

  override func accept<V: StmtVisitor, R>(_ visitor: V) throws -> R where R == V.StmtResult {
    return try visitor.visitPrintStmt(self)
  }
}

class ExpressionStmt: Stmt {
  let expr: Expr

  init(expr: Expr) {
    self.expr = expr
  }

  override func accept<V: StmtVisitor, R>(_ visitor: V) throws -> R where R == V.StmtResult {
    return try visitor.visitExpressionStmt(self)
  }
}

class VarStmt: Stmt {
  let name: String
  let initializer: Expr?

  init(name: String, initializer: Expr?) {
    self.name = name
    self.initializer = initializer
  }

  override func accept<V: StmtVisitor, R>(_ visitor: V) throws -> R where R == V.StmtResult {
    return try visitor.visitVarStmt(self)
  }
}

class BlockStmt: Stmt {
  let statements: [Stmt]

  init(statements: [Stmt]) {
    self.statements = statements
  }

  override func accept<V: StmtVisitor, R>(_ visitor: V) throws -> R where R == V.StmtResult {
    return try visitor.visitBlockStmt(self)
  }
}

class IfStmt: Stmt {
  let condition: Expr
  let thenBranch: Stmt
  let elseBranch: Stmt?

  init(condition: Expr, thenBranch: Stmt, elseBranch: Stmt?) {
    self.condition = condition
    self.thenBranch = thenBranch
    self.elseBranch = elseBranch
  }

  override func accept<V: StmtVisitor, R>(_ visitor: V) throws -> R where R == V.StmtResult {
    return try visitor.visitIfStmt(self)
  }
}

class WhileStmt: Stmt {
  let condition: Expr
  let body: Stmt

  init(condition: Expr, body: Stmt) {
    self.condition = condition
    self.body = body
  }

  override func accept<V: StmtVisitor, R>(_ visitor: V) throws -> R where R == V.StmtResult {
    return try visitor.visitWhileStmt(self)
  }
}

class FunctionStmt: Stmt {
  let name: String
  let parameters: [String]
  let body: [Stmt]

  init(name: String, parameters: [String], body: [Stmt]) {
    self.name = name
    self.parameters = parameters
    self.body = body
  }

  override func accept<V: StmtVisitor, R>(_ visitor: V) throws -> R where R == V.StmtResult {
    return try visitor.visitFunctionStmt(self)
  }
}

class ReturnStmt: Stmt {
  let value: Expr?

  init(value: Expr?) {
    self.value = value
  }

  override func accept<V: StmtVisitor, R>(_ visitor: V) throws -> R where R == V.StmtResult {
    return try visitor.visitReturnStmt(self)
  }
}

