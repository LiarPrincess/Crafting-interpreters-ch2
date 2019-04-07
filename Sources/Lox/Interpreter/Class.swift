// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

class Class: CustomStringConvertible {

  let name: String
  let superclass: Class?
  let methods: [String:Function]

  init(name: String, superclass: Class?, methods: [String:Function]) {
    self.name = name
    self.superclass = superclass
    self.methods = methods
  }

  func findMethod(_ name: String) -> Function? {
    return self.methods[name]
  }

  var description: String {
    return self.name
  }
}

// MARK: - Ctor

extension Class: Callable {

  private var initializer: Function? {
    return self.findMethod("init")
  }

  var arity: Int {
    return self.initializer?.arity ?? 0
  }

  func call(_ interpreter: Interpreter, _ arguments: [Any?]) throws -> Any? {
    let instance = Instance(class: self)

    if let initializer = self.initializer {
      try initializer.bind(instance).call(interpreter, arguments)
    }

    return instance
  }
}
