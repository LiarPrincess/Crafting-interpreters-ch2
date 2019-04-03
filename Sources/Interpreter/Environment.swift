// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

enum Value {
  case uninitialized
  case initialized(Any?)
}

class Environment {
  private let parent: Environment?
  private var values = [String:Value]()

  init() {
    self.parent = nil
  }

  init(parent: Environment) {
    self.parent = parent
  }

  func define(_ name: String, _ value: Value) {
    self.values[name] = value
  }

  func assign(_ name: String, _ value: Any?) throws {
    if self.values.contains(name) {
      values[name] = .initialized(value)
      return
    }

    if let parent = self.parent {
      try parent.assign(name, value)
      return
    }

    //TODO: proper error handling
    throw RuntimeError.undefinedVariable(name: name)
  }

  func get(_ name: String) throws -> Any? {
    if let value = self.values[name] {
      switch value {
      case let .initialized(x): return x
      case .uninitialized: throw RuntimeError.uninitalizedVariable(name: name)
      }
      return value
    }

    if let parent = self.parent {
      return try parent.get(name)
    }

    //TODO: proper error handling
    throw RuntimeError.undefinedVariable(name: name)
  }
}
