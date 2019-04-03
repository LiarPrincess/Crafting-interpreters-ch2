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
    default:
      fatalError("Unknown stmt \(stmt)")
    }
  }
}

protocol Stmt {
  func accept<V: StmtVisitor, R>(_ visitor: V) throws -> R where R == V.StmtResult
}

struct PrintStmt: Stmt {
  let expr: Expr

  func accept<V: StmtVisitor, R>(_ visitor: V) throws -> R where R == V.StmtResult {
    return try visitor.visitPrintStmt(self)
  }
}

struct ExpressionStmt: Stmt {
  let expr: Expr

  func accept<V: StmtVisitor, R>(_ visitor: V) throws -> R where R == V.StmtResult {
    return try visitor.visitExpressionStmt(self)
  }
}

struct VarStmt: Stmt {
  let name: String
  let initializer: Expr?

  func accept<V: StmtVisitor, R>(_ visitor: V) throws -> R where R == V.StmtResult {
    return try visitor.visitVarStmt(self)
  }
}

struct BlockStmt: Stmt {
  let statements: [Stmt]

  func accept<V: StmtVisitor, R>(_ visitor: V) throws -> R where R == V.StmtResult {
    return try visitor.visitBlockStmt(self)
  }
}
