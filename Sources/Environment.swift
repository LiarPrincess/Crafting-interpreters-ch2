// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

struct Environment {
  private var values = [String:Any?]()

  mutating func define(_ name: String, _ value: Any?) {
    self.values[name] = value
  }

  func get(_ name: String) throws -> Any? {
    if let value = self.values[name] {
      return value
    }

    // todo: proper error handling
    let token = Token(type: .identifier("name"), location: SourceLocation(line: 0, column: 0))
    throw RuntimeError(token: token, type: .undefinedVariable(name))
  }
}
