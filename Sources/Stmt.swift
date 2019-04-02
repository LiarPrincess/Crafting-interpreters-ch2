// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

protocol StmtVisitor {
  func visitPrintStmt(_ stmt: PrintStmt) throws
  func visitExpressionStmt(_ stmt: ExpressionStmt) throws
}

extension StmtVisitor {
  func visit(_ stmt: Stmt) throws {
    switch stmt {
    case let stmt as PrintStmt:
      try self.visitPrintStmt(stmt)
    case let stmt as ExpressionStmt:
      try self.visitExpressionStmt(stmt)
    default:
      fatalError("Unknown stmt \(stmt)")
    }
  }
}

protocol Stmt {
  func accept(_ visitor: StmtVisitor) throws
}

struct PrintStmt: Stmt {
  let expr: Expr

  func accept(_ visitor: StmtVisitor) throws {
    try visitor.visitPrintStmt(self)
  }
}

struct ExpressionStmt: Stmt {
  let expr: Expr

  func accept(_ visitor: StmtVisitor) throws {
    try visitor.visitExpressionStmt(self)
  }
}
