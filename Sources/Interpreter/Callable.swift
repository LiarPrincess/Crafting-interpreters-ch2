// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

protocol Callable {
  var arity: Int { get }
  func call(_ interpreter: Interpreter, _ arguments: [Any?]) throws -> Any?
}

struct Function: Callable {

  let declaration: FunctionStmt

  var arity: Int {
    return self.declaration.parameters.count
  }

  func call(_ interpreter: Interpreter, _ arguments: [Any?]) throws -> Any? {
    let environment = Environment(parent: interpreter.environment)
    for (index, name) in self.declaration.parameters.enumerated() {
      environment.define(name, .initialized(arguments[index]))
    }

    try interpreter.execute(self.declaration.body, in: environment)
    return nil
  }
}

struct ClockCallable: Callable {

  let arity = 0

  func call(_ interpreter: Interpreter, _ arguments: [Any?]) throws -> Any? {
    let now = Date()
    return now.timeIntervalSince1970
  }
}
