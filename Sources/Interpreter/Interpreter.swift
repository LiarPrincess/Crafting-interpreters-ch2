// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

// swiftlint:disable force_cast

enum RuntimeError: Error, CustomStringConvertible {
  case undefinedVariable(name: String)
  case invalidOperandType(type: String)
  case invalidOperandTypes(left: String, right: String)

  var description: String {
    switch self {
    case let .undefinedVariable(name): return "Undefined variable: \(name)."
    case let .invalidOperandType(type): return "Invalid operand type: \(type)."
    case let .invalidOperandTypes(left, right): return "Invalid operand types: \(left) and \(right)."
    }
  }
}

class Interpreter: StmtVisitor, ExprVisitor {

  typealias StmtResult = Void
  typealias ExprResult = Any?

  private var environment = Environment()

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

  private func execute(_ statement: Stmt) throws {
    try statement.accept(self)
  }

  // MARK: - Statements

  func visitPrintStmt(_ stmt: PrintStmt) throws {
    let value = try self.evaluate(stmt.expr)
    let valueString = self.getDebugDescription(value)
    print(valueString)
  }

  func visitExpressionStmt(_ stmt: ExpressionStmt) throws {
    _ = try self.evaluate(stmt.expr)
  }

  func visitVarStmt(_ stmt: VarStmt) throws {
    var value: Any?
    if let initializer = stmt.initializer {
      value = try self.evaluate(initializer)
    }

    self.environment.define(stmt.name, value)
  }

  // MARK: - Expressions

  func visitBoolExpr(_ expr: BoolExpr) throws -> Any? {
    return expr.value
  }

  func visitNumberExpr(_ expr: NumberExpr) throws -> Any? {
    return expr.value
  }

  func visitStringExpr(_ expr: StringExpr) throws -> Any? {
    return expr.value
  }

  func visitNilExpr(_ expr: NilExpr) throws -> Any? {
    return nil
  }

  func visitUnaryExpr(_ expr: UnaryExpr) throws -> Any? {
    let right = try self.evaluate(expr.right)

    switch expr.op {
    case .minus:
      let right = try self.checkNumberOperand(right)
      return -right
    case .bang:
      return self.isTruthy(right)
    default:
      return nil
    }
  }

  private func isTruthy(_ value: Any?) -> Bool {
    switch value {
    case .none: return false
    case let .some(bool) where bool is Bool: return bool as! Bool
    default: return true
    }
  }

  func visitBinaryExpr(_ expr: BinaryExpr) throws -> Any? {
    let left = try self.evaluate(expr.left)
    let right = try self.evaluate(expr.right)

    switch expr.op {
    case .plus:
      if self.isNumberOperand(left) && self.isNumberOperand(right) {
        return try self.performBinaryNumberOperation(left, right, +)
      }
      if self.isStringOperand(left) || self.isStringOperand(right) {
        if left == nil || right == nil { return nil }
        return try self.performBinaryStringOperation(String(describing: left!), String(describing: right!), +)
      }

      let leftDescription  = self.getDebugDescription(left)
      let rightDescription = self.getDebugDescription(right)
      throw RuntimeError.invalidOperandTypes(left: leftDescription, right: rightDescription)

    case .minus: return try self.performBinaryNumberOperation(left, right, -)
    case .slash: return try self.performBinaryNumberOperation(left, right, /)
    case .star:  return try self.performBinaryNumberOperation(left, right, *)

    case .greater:      return try self.performBinaryNumberOperation(left, right, >)
    case .greaterEqual: return try self.performBinaryNumberOperation(left, right, >=)
    case .less:         return try self.performBinaryNumberOperation(left, right, <)
    case .lessEqual:    return try self.performBinaryNumberOperation(left, right, <=)

    case .equalEqual: return try  self.isEqual(left, right)
    case .bangEqual:  return try !self.isEqual(left, right)

    default:
      return nil
    }
  }
  func visitGroupingExpr(_ expr: GroupingExpr) throws -> Any? {
    return try self.evaluate(expr.expr)
  }

  private func evaluate(_ expr: Expr) throws -> Any? {
    return try expr.accept(self)
  }

  func visitVariableExpr(_ expr: VariableExpr) throws -> Any? {
    return try self.environment.get(expr.name)
  }

  func visitAssignExpr(_ expr: AssignExpr) throws -> Any? {
    let value = try self.evaluate(expr.value)
    try self.environment.assign(expr.name, value)
    return value
  }

  // MARK: - Binary operations

  private typealias BinaryOperation<T> = (T, T) -> Any?

  private func performBinaryBoolOperation(_ left: Any?, _ right: Any?, _ op: BinaryOperation<Bool>) throws -> Any? {
    let left = try self.checkBoolOperand(left)
    let right = try self.checkBoolOperand(right)
    return op(left, right)
  }

  private func performBinaryNumberOperation(_ left: Any?, _ right: Any?, _ op: BinaryOperation<Double>) throws -> Any? {
    let left = try self.checkNumberOperand(left)
    let right = try self.checkNumberOperand(right)
    return op(left, right)
  }

  private func performBinaryStringOperation(_ left: Any?, _ right: Any?, _ op: BinaryOperation<String>) throws -> Any? {
    let left = try self.checkStringOperand(left)
    let right = try self.checkStringOperand(right)
    return op(left, right)
  }

  private func isEqual(_ left: Any?, _ right: Any?) throws -> Bool {
    if left == nil && right == nil { return true }
    if left == nil || right == nil { return false }

    if self.isBoolOperand(left) && self.isBoolOperand(right) {
      return try self.performBinaryBoolOperation(left, right, ==) as! Bool
    }

    if self.isNumberOperand(left) && self.isNumberOperand(right) {
      return try self.performBinaryNumberOperation(left, right, ==) as! Bool
    }

    if self.isStringOperand(left) && self.isStringOperand(right) {
      return try self.performBinaryStringOperation(left, right, ==) as! Bool
    }

    return true
  }

  // MARK: - Checks

  private func isBoolOperand(_ operand: Any?) -> Bool {
    return operand is Bool
  }

  private func isNumberOperand(_ operand: Any?) -> Bool {
    return operand is Double
  }

  private func isStringOperand(_ operand: Any?) -> Bool {
    return operand is String
  }

  private func checkBoolOperand(_ operand: Any?) throws -> Bool {
    guard self.isBoolOperand(operand) else {
      let operandDescription = self.getDebugDescription(operand)
      throw RuntimeError.invalidOperandType(type: operandDescription)
    }

    return operand as! Bool
  }

  private func checkNumberOperand(_ operand: Any?) throws -> Double {
    guard self.isNumberOperand(operand) else {
      let operandDescription = self.getDebugDescription(operand)
      throw RuntimeError.invalidOperandType(type: operandDescription)
    }

    return operand as! Double
  }

  private func checkStringOperand(_ operand: Any?) throws -> String {
    guard self.isStringOperand(operand) else {
      let operandDescription = self.getDebugDescription(operand)
      throw RuntimeError.invalidOperandType(type: operandDescription)
    }

    return operand as! String
  }

  // MARK: - Errors

  private func getDebugDescription(_ value: Any?) -> String {
    guard let value = value else {
      return "nil"
    }

    if self.isStringOperand(value) {
      return "\"\(value)\""
    }

    return String(describing: value)
  }
}
