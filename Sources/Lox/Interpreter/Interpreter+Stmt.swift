// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

extension Interpreter {

  func visitPrintStmt(_ stmt: PrintStmt) throws {
    let value = try self.evaluate(stmt.expr)
    let valueString = self.show(value)
    print(valueString)
  }

  private func show(_ value: Any?) -> String {
    guard let value = value else {
      return "nil"
    }

    return String(describing: value)
  }

  func visitBlockStmt(_ stmt: BlockStmt) throws {
    let environment = Environment(parent: self.environment)
    try self.execute(stmt.statements, in: environment)
  }

  func visitExpressionStmt(_ stmt: ExpressionStmt) throws {
    _ = try self.evaluate(stmt.expr)
  }

  func visitIfStmt(_ stmt: IfStmt) throws {
    let condition = try self.evaluate(stmt.condition)

    if self.isTruthy(condition) {
      try self.execute(stmt.thenBranch)
    }
    else if let elseBranch = stmt.elseBranch {
      try self.execute(elseBranch)
    }
  }

  func visitWhileStmt(_ stmt: WhileStmt) throws {
    while let condition = try self.evaluate(stmt.condition), self.isTruthy(condition) {
      try self.execute(stmt.body)
    }
  }

  func visitReturnStmt(_ stmt: ReturnStmt) throws {
    let result = stmt.value == nil ? nil : try self.evaluate(stmt.value!)
    throw Return(value: result)
  }
}
