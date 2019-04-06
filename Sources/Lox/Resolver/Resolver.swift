// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

enum FunctionType {
  case none
  case function
  case method
}

class Resolver: StmtVisitor, ExprVisitor {

  typealias StmtResult = Void
  typealias ExprResult = Void

  let interpreter: Interpreter
  var scopes = [ScopeInfo]()
  var currentFunction = FunctionType.none

  init(_ interpreter: Interpreter) {
    self.interpreter = interpreter
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

  func resolveLocal(_ expr: Expr, _ name: String) {
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

  func beginScope() -> ScopeInfo {
    let scope = ScopeInfo()
    self.scopes.append(scope)
    return scope
  }

  func endScope() {
    if let scope = self.scopes.last {
      for (name, variable) in scope.variables where !variable.isUsed {
        print("Unused variable: \(name)")
      }
    }

    self.scopes.removeLast()
  }

  // MARK: - Declare, define

  func declare(_ name: String) throws {
    guard let scope = self.scopes.last else { return }

    if scope.variables.contains(name) {
      throw ResolverError.variableAlreadyDeclared(name: name)
    }

    scope.variables[name] = VariableInfo(state: .declared)
  }

  func define(_ name: String) {
    guard let scope = self.scopes.last else { return }

    if let variable = scope.variables[name] {
      variable.state = .initialized
    }
    else {
      scope.variables[name] = VariableInfo(state: .initialized)
    }
  }
}
