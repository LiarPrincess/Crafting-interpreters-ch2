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

  func visitBlockStmt(_ stmt: BlockStmt) throws -> String {
    return try self.parenthesize(name: "block", stmts: stmt.statements)
  }

  func visitVarStmt(_ stmt: VarStmt) throws -> String {
    switch stmt.initializer {
    case let .some(initializer):
      return try parenthesize(name: "var @\(stmt.name)", exprs: initializer)
    case .none:
      return try parenthesize(name: "var @\(stmt.name)")
    }
  }

  func visitIfStmt(_ stmt: IfStmt) throws -> String {
    var childs: [String] = [
      self.parenthesize(name: "condition", childs: [try self.visit(stmt.condition)]),
      self.parenthesize(name: "then",      childs: [try self.visit(stmt.thenBranch)])
    ]

    if let elseBranch = stmt.elseBranch {
      let elseString = self.parenthesize(name: "else", childs: [try self.visit(elseBranch)])
      childs.append(elseString)
    }

    return self.parenthesize(name: "if", childs: childs)
  }

  func visitWhileStmt(_ stmt: WhileStmt) throws -> String {
    let body = self.parenthesize(name: "body", childs: [try self.visit(stmt.body)])
    return self.parenthesize(name: "while", childs: [body])
  }

  func visitFunctionStmt(_ stmt: FunctionStmt) throws -> String {
    let name = self.parenthesize(name: "name", childs: [stmt.name])
    let body = try self.parenthesize(name: "body", stmts: stmt.body)
    return self.parenthesize(name: "fun", childs: [name, body])
  }

  func visitReturnStmt(_ stmt: ReturnStmt) throws -> String {
    let exprs = stmt.value == nil ? [] : [stmt.value!]
    return try self.parenthesize(name: "return", exprs: exprs)
  }

  // MARK: - Expressions

  func visitBoolExpr(_ expr: BoolExpr) throws -> String {
    return String(describing: expr.value)
  }

  func visitNumberExpr(_ expr: NumberExpr) throws -> String {
    return String(describing: expr.value)
  }

  func visitStringExpr(_ expr: StringExpr) throws -> String {
    return "\"\(expr.value)\""
  }

  func visitNilExpr(_ expr: NilExpr) throws -> String {
    return "nil"
  }

  func visitUnaryExpr(_ expr: UnaryExpr) throws -> String {
    let op = expr.op.description
    return try self.parenthesize(name: op, exprs: expr.right)
  }

  func visitBinaryExpr(_ expr: BinaryExpr) throws -> String {
    let op = expr.op.description
    return try self.parenthesize(name: op, exprs: expr.left, expr.right)
  }

  func visitLogicalExpr(_ expr: LogicalExpr) throws -> String {
    let op = expr.op.description
    return try self.parenthesize(name: op, exprs: expr.left, expr.right)
  }

  func visitGroupingExpr(_ expr: GroupingExpr) throws -> String {
    return try self.parenthesize(name: "group", exprs: expr.expr)
  }

  func visitVariableExpr(_ expr: VariableExpr) throws -> String {
    return "@\(expr.name)"
  }

  func visitAssignExpr(_ expr: AssignExpr) throws -> String {
    return try self.parenthesize(name: "set @\(expr.name)", exprs: expr.value)
  }

  func visitCallExpr(_ expr: CallExpr) throws -> String {
    let calee = self.parenthesize(name: "name", childs: [try self.visit(expr.calee)])
    let args = try self.parenthesize(name: "args", exprs: expr.arguments)
    return self.parenthesize(name: "call", childs: [calee, args])
  }

  // MARK: - Parenthesize

  private func parenthesize(name: String, childs: [String]) -> String {
    return "(\(name) \(childs.joined(separator: " ")))"
  }

  private func parenthesize(name: String, stmts: [Stmt]) throws -> String {
    let childs = try stmts.map { try $0.accept(self) }
    return self.parenthesize(name: name, childs: childs)
  }

  private func parenthesize(name: String, exprs: Expr...) throws -> String {
    return try self.parenthesize(name: name, exprs: exprs)
  }

  private func parenthesize(name: String, exprs: [Expr]) throws -> String {
    let childs = try exprs.map { try $0.accept(self) }
    return self.parenthesize(name: name, childs: childs)
  }
}
