// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

private enum Value {
  case uninitialized
  case initialized(Any?)
}

class Environment {
  private let parent: Environment?
  private var values = [String:Value]()

  init(parent: Environment? = nil) {
    self.parent = parent
  }

  /// Define uninitialized variable
  func define(_ name: String) {
    self.values[name] = .uninitialized
  }

  /// Define initialized variable
  func define(_ name: String, _ value: Any?) {
    self.values[name] = .initialized(value)
  }

  /// Re-assign variable
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

  /// Re-assign variable in environment at given depth
  func assign(_ name: String, _ value: Any?, at depth: Int) throws {
    let environment = self.getAncestor(at: depth)
    assert(environment != nil, "Invalid environment depth")

    environment?.values[name] = .initialized(value)
  }

  /// Get variable value
  func get(_ name: String) throws -> Any? {
    printDebug("Looking for ordinal variable: \(name)")

    if let value = self.values[name] {
      switch value {
      case let .initialized(x): return x
      case .uninitialized: throw RuntimeError.uninitalizedVariable(name: name)
      }
    }

    if let parent = self.parent {
      return try parent.get(name)
    }

    //TODO: proper error handling
    throw RuntimeError.undefinedVariable(name: name)
  }

  /// Get variable value from environment at given depth
  func get(_ name: String, at depth: Int) throws -> Any? {
    printDebug("Looking for local variable: \(name) at depth: \(depth)")

    let environment = self.getAncestor(at: depth)
    assert(environment != nil, "Invalid environment depth")

    if let value = environment?.values[name] {
      switch value {
      case let .initialized(x): return x
      case .uninitialized: throw RuntimeError.uninitalizedVariable(name: name)
      }
    }
    //TODO: proper error handling
    throw RuntimeError.undefinedVariable(name: name)
  }

  private func getAncestor(at depth: Int) -> Environment? {
    var environment: Environment? = self
    for _ in 0..<depth {
      environment = environment?.parent
    }
    return environment
  }
}
