// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

struct Instance {
  let `class`: Class
}

struct Class: Callable {

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
