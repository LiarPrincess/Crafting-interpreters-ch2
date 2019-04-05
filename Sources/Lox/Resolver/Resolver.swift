// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

enum ResolverErrors: Error, CustomStringConvertible {
  case topLevelReturn
  case variableAlreadyDeclared(name: String)
  case variableUsedInOwnInitializer(name: String)

  var description: String {
    switch self {
    case .topLevelReturn:
      return "Cannot return from top-level code."
    case let .variableAlreadyDeclared(name):
      return "Variable '\(name)' was already declared in this scope."
    case let .variableUsedInOwnInitializer(name):
      return "Cannot read variable '\(name)' in its own initializer."
    }
  }
}

private enum FunctionType {
  case none
  case function
}

class Resolver: StmtVisitor, ExprVisitor {

  typealias StmtResult = Void
  typealias ExprResult = Void

  private let interpreter: Interpreter
  private var scopes = [ScopeInfo]()
  private var currentFunction = FunctionType.none

  init(_ interpreter: Interpreter) {
    self.interpreter = interpreter
  }

  // MARK: - Stmt

  func visitPrintStmt(_ stmt: PrintStmt) throws {
    try self.resolve(stmt.expr)
  }

  func visitExpressionStmt(_ stmt: ExpressionStmt) throws {
    try self.resolve(stmt.expr)
  }

  func visitVarStmt(_ stmt: VarStmt) throws {
    try self.declare(stmt.name)
    if let initializer = stmt.initializer  {
      try self.resolve(initializer)
    }
    self.define(stmt.name)
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

  func visitFunctionStmt(_ stmt: FunctionStmt) throws {
    try self.declare(stmt.name)
    self.define(stmt.name)

    try self.resolveFunction(stmt, type: .function)
  }

  func visitReturnStmt(_ stmt: ReturnStmt) throws {
    guard self.currentFunction != .none else {
      throw ResolverErrors.topLevelReturn
    }

    if let value = stmt.value {
      try self.resolve(value)
    }
  }

  // MARK: - Expr

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
      throw ResolverErrors.variableUsedInOwnInitializer(name: expr.name)
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

  // MARK: - Reolve

  func resolve(_ expr: Expr) throws {
    try expr.accept(self)
  }

  func resolve(_ stmt: Stmt) throws {
    try stmt.accept(self)
  }

  func resolve(_ stmts: [Stmt]) throws {
    for statement in stmts {
      try self.resolve(statement)
    }
  }

  private func resolveFunction(_ stmt: FunctionStmt, type: FunctionType) throws {
    let enclosingFunction = self.currentFunction
    self.currentFunction = type
    self.beginScope()

    for param in stmt.parameters {
      try self.declare(param)
      self.define(param)
    }

    try self.resolve(stmt.body)

    self.endScope()
    self.currentFunction = enclosingFunction
  }

  private func resolveLocal(_ expr: Expr, _ name: String) {
    for (depth, scope) in self.scopes.reversed().enumerated() {
      if scope.variables.contains(name) {
        printDebug("variable: \(name) is at depth: \(depth)")
        self.interpreter.resolve(expr, depth)
        return
      }
    }

    // Not found. Assume it is global.
  }

  // MARK: - Scope

  private func beginScope() {
    self.scopes.append(ScopeInfo())
  }

  private func endScope() {
    if let scope = self.scopes.last {
      for (name, variable) in scope.variables where !variable.isUsed {
        print("Unused variable: \(name)")
      }
    }

    self.scopes.removeLast()
  }

  private func declare(_ name: String) throws {
    guard let scope = self.scopes.last else { return }

    if scope.variables.contains(name) {
      throw ResolverErrors.variableAlreadyDeclared(name: name)
    }

    scope.variables[name] = VariableInfo(state: .declared)
  }

  private func define(_ name: String) {
    guard let scope = self.scopes.last else { return }

    if let variable = scope.variables[name] {
      variable.state = .initialized
    }
    else {
      scope.variables[name] = VariableInfo(state: .initialized)
    }
  }
}
