// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

class Function: Callable {

  let declaration: FunctionStmt
  let closure: Environment

  var arity: Int {
    return self.declaration.parameters.count
  }

  init(declaration: FunctionStmt, closure: Environment) {
    self.declaration = declaration
    self.closure = closure
  }

  func call(_ interpreter: Interpreter, _ arguments: [Any?]) throws -> Any? {
    let environment = Environment(parent: self.closure)
    for (index, name) in self.declaration.parameters.enumerated() {
      environment.define(name, arguments[index])
    }

    do {
      try interpreter.execute(self.declaration.body, in: environment)
    }
    catch let error as Return {
      return error.value
    }

    return nil
  }

  func bind(_ instance: Instance) -> Function {
    let environment = Environment(parent: self.closure)
    environment.define("this", instance)
    return Function(declaration: self.declaration, closure: environment)
  }
}
