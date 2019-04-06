// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

class Class {

  let name: String
  let methods: [String:Function]

  init(name: String, methods: [String:Function]) {
    self.name = name
    self.methods = methods
  }
}

// MARK: - Ctor

extension Class: Callable {

  var arity: Int { return 0 }

  func call(_ interpreter: Interpreter, _ arguments: [Any?]) throws -> Any? {
    let instance = Instance(class: self)
    return instance
  }
}
