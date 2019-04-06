// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

class Instance {

  let `class`: Class
  private var fields = [String:Any?]()

  init(class: Class) {
    self.class = `class`
  }

  func get(_ name: String) throws -> Any? {
    if let value = self.fields[name] {
      return value
    }
    throw RuntimeError.getUndefinedPropery(name: name)
  }
}

class Class: Callable {

  let arity = 0
  let name: String

  init(name: String) {
    self.name = name
  }

  func call(_ interpreter: Interpreter, _ arguments: [Any?]) throws -> Any? {
    let instance = Instance(class: self)
    return instance
  }
}
