// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

class Instance: CustomStringConvertible {

  let `class`: Class
  private var fields = [String:Any?]()

  init(class: Class) {
    self.class = `class`
  }

  func get(_ name: String) throws -> Any? {
    if let value = self.fields[name] {
      return value
    }

    if let method = self.class.findMethod(name) {
      return method.bind(self)
    }

    throw RuntimeError.getUndefinedPropery(name: name)
  }

  func set(_ name: String, to value: Any?) {
    self.fields[name] = value
  }

  var description: String {
    return "\(self.class)(\(self.fields))"
  }
}
