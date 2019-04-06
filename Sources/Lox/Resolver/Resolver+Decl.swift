// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

extension Resolver {

  func visitVarStmt(_ stmt: VarStmt) throws {
    try self.declare(stmt.name)
    if let initializer = stmt.initializer  {
      try self.resolve(initializer)
    }
    self.define(stmt.name)
  }

  func visitFunctionStmt(_ stmt: FunctionStmt) throws {
    try self.declare(stmt.name)
    self.define(stmt.name)

    try self.resolveFunction(stmt, type: .function)
  }

  func visitClassStmt(_ stmt: ClassStmt) throws {
    let enclosingClass = self.currentClass
    self.currentClass = .class
    defer { self.currentClass = enclosingClass }

    try self.declare(stmt.name)
    self.define(stmt.name)

    let scope = self.beginScope()
    defer { self.endScope() }

    scope.variables["this"] = VariableInfo(state: .initialized)

    for method in stmt.methods {
      let type = FunctionType.method
      try self.resolveFunction(method, type: type)
    }
  }

  private func resolveFunction(_ stmt: FunctionStmt, type: FunctionType) throws {
    let enclosingFunction = self.currentFunction
    self.currentFunction = type
    defer { self.currentFunction = enclosingFunction }

    self.beginScope()
    defer { self.endScope() }

    for param in stmt.parameters {
      try self.declare(param)
      self.define(param)
    }

    try self.resolve(stmt.body)
  }
}
