// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

protocol InterpreterType {
  func interpret(_ statements: [Stmt])
}

class Interpreter: InterpreterType {

  typealias StmtResult = Void
  typealias ExprResult = Any?

  private let globals: Environment = {
    let result = Environment()
    result.define("clock", .initialized(ClockCallable()))
    return result
  }()

  lazy var environment = self.globals

  func interpret(_ statements: [Stmt]) {
    do {
      for statement in statements {
        try self.execute(statement)
      }
    }
    catch let error as RuntimeError {
      let location = SourceLocation.tmp
      Lox.runtimeError(location: location, message: error.description)
    }
    catch {
      fatalError("Unknown error")
    }
  }

  // MARK: - Execute

  func execute(_ statement: Stmt) throws {
    try statement.accept(self)
  }

  func executeBlock(_ statements: [Stmt], in environment: Environment) throws {
    let previous = self.environment
    defer { self.environment = previous }

    self.environment = environment
    try statements.forEach { try self.execute($0) }
  }

  // MARK: - Evaluate

  func evaluate(_ expr: Expr) throws -> Any? {
    return try expr.accept(self)
  }

  func isTruthy(_ value: Any?) -> Bool {
    guard let value = value else { return false }
    return (value as? Bool) ?? true
  }

  // MARK: - Errors

  func getType(_ value: Any?) -> String {
    if value == nil { return "nil" }
    return value.self.debugDescription
  }
}
