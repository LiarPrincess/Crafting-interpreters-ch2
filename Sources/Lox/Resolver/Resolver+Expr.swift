// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

extension Resolver {

  func visitBoolExpr(_ expr: BoolExpr) throws { }
  func visitNumberExpr(_ expr: NumberExpr) throws { }
  func visitStringExpr(_ expr: StringExpr) throws { }
  func visitNilExpr(_ expr: NilExpr) throws { }

  func visitUnaryExpr(_ expr: UnaryExpr) throws {
    try self.resolve(expr.right)
  }

  func visitBinaryExpr(_ expr: BinaryExpr) throws {
    try self.resolve(expr.left)
    try self.resolve(expr.right)
  }

  func visitLogicalExpr(_ expr: LogicalExpr) throws {
    try self.resolve(expr.left)
    try self.resolve(expr.right)
  }

  func visitGroupingExpr(_ expr: GroupingExpr) throws {
    try self.resolve(expr.expr)
  }

  func visitVariableExpr(_ expr: VariableExpr) throws {
    guard let scope = self.scopes.last else { return }

    if let variable = scope.variables[expr.name], variable.state == .declared {
      throw ResolverError.variableUsedInOwnInitializer(name: expr.name)
    }

    if let variable = scope.variables[expr.name] {
      variable.isUsed = true
    }
    self.resolveLocal(expr, expr.name)
  }

  func visitAssignExpr(_ expr: AssignExpr) throws {
    try self.resolve(expr.value)
    self.resolveLocal(expr, expr.name)
  }

  func visitCallExpr(_ expr: CallExpr) throws {
    try self.resolve(expr.calee)

    for arg in expr.arguments {
      try self.resolve(arg)
    }
  }

  func visitGetExpr(_ expr: GetExpr) throws {
    try self.resolve(expr.object)
  }

  func visitSetExpr(_ expr: SetExpr) throws {
    try self.resolve(expr.object)
    try self.resolve(expr.value)
  }

  func visitThisExpr(_ expr: ThisExpr) throws {
    if self.currentClass == .none {
      throw ResolverError.thisUsedOutsideOfClass
    }

    self.resolveLocal(expr, "this")
  }

  func visitSuperExpr(_ expr: SuperExpr) throws {
    if self.currentClass == .none {
      throw ResolverError.superUsedOutsideOfClass
    }

    if self.currentClass == .class {
      throw ResolverError.superUsedWithoutSuperclass
    }

    self.resolveLocal(expr, "super")
  }
}
