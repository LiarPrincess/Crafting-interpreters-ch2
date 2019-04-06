// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

extension Interpreter {

  func visitVarStmt(_ stmt: VarStmt) throws {
    if let initializer = stmt.initializer {
      let value = try self.evaluate(initializer)
      self.environment.define(stmt.name, value)
    } else {
      self.environment.define(stmt.name)
    }
  }

  func visitFunctionStmt(_ stmt: FunctionStmt) throws {
    let function = Function(declaration: stmt, closure: self.environment)
    self.environment.define(stmt.name, function)
  }

  func visitClassStmt(_ stmt: ClassStmt) throws {
    self.environment.define(stmt.name)

    var methods = [String:Function]()
    for method in stmt.methods {
      let isInitializer = stmt.name == "init"
      let function = Function(declaration: method, closure: self.environment, isInitializer: isInitializer)
      methods[method.name] = function
    }

    let klass = Class(name: stmt.name, methods: methods)
    try self.environment.assign(stmt.name, klass)
  }
}
