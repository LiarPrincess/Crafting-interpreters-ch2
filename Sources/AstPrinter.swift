// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

class AstPrinter: StmtVisitor, ExprVisitor {

  typealias StmtResult = String
  typealias ExprResult = String

  // MARK: - Statements

  func visitPrintStmt(_ stmt: PrintStmt) throws -> String {
    return try parenthesize(name: "print", exprs: stmt.expr)
  }

  func visitExpressionStmt(_ stmt: ExpressionStmt) throws -> String {
    return try parenthesize(name: "expr", exprs: stmt.expr)
  }

  func visitVarStmt(_ stmt: VarStmt) throws -> String {
    switch stmt.initializer {
    case let .some(initializer):
      return try parenthesize(name: "var @\(stmt.name)", exprs: initializer)
    case .none:
      return try parenthesize(name: "var @\(stmt.name)")
    }
  }

  // MARK: - Expressions

  func visitBoolExpr(_ expr: BoolExpr) throws -> String {
    return String(describing: expr.value)
  }

  func visitNumberExpr(_ expr: NumberExpr) throws -> String {
    return String(describing: expr.value)
  }

  func visitStringExpr(_ expr: StringExpr) throws -> String {
    return expr.value
  }

  func visitNilExpr(_ expr: NilExpr) throws -> String {
    return "nil"
  }

  func visitUnaryExpr(_ expr: UnaryExpr) throws -> String {
    let op = String(describing: expr.op.type)
    return try self.parenthesize(name: op, exprs: expr.right)
  }

  func visitBinaryExpr(_ expr: BinaryExpr) throws -> String {
    let op = String(describing: expr.op.type)
    return try self.parenthesize(name: op, exprs: expr.left, expr.right)
  }

  func visitGroupingExpr(_ expr: GroupingExpr) throws -> String {
    return try self.parenthesize(name: "group", exprs: expr.expr)
  }

  func visitVariableExpr(_ expr: VariableExpr) throws -> String {
    return expr.name
  }

  private func parenthesize(name: String, exprs: Expr...) throws -> String {
    let exprsString = try exprs.map { e in try e.accept(self) }.joined(separator: " ")
    return "(\(name) \(exprsString))"
  }
}
