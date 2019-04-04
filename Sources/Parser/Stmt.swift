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

struct IfStmt: Stmt {
  let condition: Expr
  let thenBranch: Stmt
  let elseBranch: Stmt?

  func accept<V: StmtVisitor, R>(_ visitor: V) throws -> R where R == V.StmtResult {
    return try visitor.visitIfStmt(self)
  }
}

struct WhileStmt: Stmt {
  let condition: Expr
  let body: Stmt

  func accept<V: StmtVisitor, R>(_ visitor: V) throws -> R where R == V.StmtResult {
    return try visitor.visitWhileStmt(self)
  }
}

struct FunctionStmt: Stmt {
  let name: String
  let parameters: [String]
  let body: Stmt

  func accept<V: StmtVisitor, R>(_ visitor: V) throws -> R where R == V.StmtResult {
    return try visitor.visitFunctionStmt(self)
  }
}

struct ReturnStmt: Stmt {
  let value: Expr?

  func accept<V: StmtVisitor, R>(_ visitor: V) throws -> R where R == V.StmtResult {
    return try visitor.visitReturnStmt(self)
  }
}
