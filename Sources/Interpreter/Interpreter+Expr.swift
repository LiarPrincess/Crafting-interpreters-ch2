// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

extension Interpreter: ExprVisitor {

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
      let right = try self.checkNumberOperand(right, "-")
      return -right
    case .bang:
      return self.isTruthy(right)
    default:
      return nil
    }
  }

  // swiftlint:disable:next cyclomatic_complexity
  func visitBinaryExpr(_ expr: BinaryExpr) throws -> Any? {
    let left = try self.evaluate(expr.left)
    let right = try self.evaluate(expr.right)

    switch expr.op {
    case .plus:
      if self.isNumberOperand(left) && self.isNumberOperand(right) {
        return try self.performBinaryNumberOperation(left, right, "+", +)
      }
      if self.isStringOperand(left) || self.isStringOperand(right) {
        if left == nil || right == nil { return nil }
        return try self.performBinaryStringOperation(String(describing: left!), String(describing: right!), "+", +)
      }

      throw RuntimeError.invalidOperandTypes(op: "+", leftType: self.getType(left), rightType: self.getType(right))

    case .minus: return try self.performBinaryNumberOperation(left, right, "-", -)
    case .slash: return try self.performBinaryNumberOperation(left, right, "/", /)
    case .star:  return try self.performBinaryNumberOperation(left, right, "*", *)

    case .greater:      return try self.performBinaryNumberOperation(left, right, ">", >)
    case .greaterEqual: return try self.performBinaryNumberOperation(left, right, ">=", >=)
    case .less:         return try self.performBinaryNumberOperation(left, right, "<", <)
    case .lessEqual:    return try self.performBinaryNumberOperation(left, right, "<=", <=)

    case .equalEqual: return try  self.isEqual(left, right)
    case .bangEqual:  return try !self.isEqual(left, right)

    default:
      return nil
    }
  }

  func visitLogicalExpr(_ expr: LogicalExpr) throws -> Any? {
    let left = try self.evaluate(expr.left)
    let isLeftTruthy = self.isTruthy(left)

    if expr.op == .and && !isLeftTruthy {
      return left
    }

    if expr.op == .or && isLeftTruthy {
      return left
    }

    return try self.evaluate(expr.right)
  }

  func visitGroupingExpr(_ expr: GroupingExpr) throws -> Any? {
    return try self.evaluate(expr.expr)
  }

  func visitVariableExpr(_ expr: VariableExpr) throws -> Any? {
    return try self.environment.get(expr.name)
  }

  func visitAssignExpr(_ expr: AssignExpr) throws -> Any? {
    let value = try self.evaluate(expr.value)
    try self.environment.assign(expr.name, value)
    return value
  }
}

// MARK: - Binary operations

// swiftlint:disable force_cast

extension Interpreter {

  fileprivate func isBoolOperand(_ operand: Any?) -> Bool {
    return operand is Bool
  }

  fileprivate func isNumberOperand(_ operand: Any?) -> Bool {
    return operand is Double
  }

  fileprivate func isStringOperand(_ operand: Any?) -> Bool {
    return operand is String
  }

  fileprivate func checkBoolOperand(_ operand: Any?, _ op: String) throws -> Bool {
    guard self.isBoolOperand(operand) else {
      throw RuntimeError.invalidOperandType(op: op, type: self.getType(operand))
    }

    return operand as! Bool
  }

  fileprivate func checkNumberOperand(_ operand: Any?, _ op: String) throws -> Double {
    guard self.isNumberOperand(operand) else {
      throw RuntimeError.invalidOperandType(op: op, type: self.getType(operand))
    }

    return operand as! Double
  }

  fileprivate func checkStringOperand(_ operand: Any?, _ op: String) throws -> String {
    guard self.isStringOperand(operand) else {
      throw RuntimeError.invalidOperandType(op: op, type: self.getType(operand))
    }

    return operand as! String
  }

  fileprivate func isEqual(_ left: Any?, _ right: Any?) throws -> Bool {
    if left == nil && right == nil { return true }
    if left == nil || right == nil { return false }

    if self.isBoolOperand(left) && self.isBoolOperand(right) {
      return try self.performBinaryBoolOperation(left, right, "==", ==) as! Bool
    }

    if self.isNumberOperand(left) && self.isNumberOperand(right) {
      return try self.performBinaryNumberOperation(left, right, "==", ==) as! Bool
    }

    if self.isStringOperand(left) && self.isStringOperand(right) {
      return try self.performBinaryStringOperation(left, right, "==", ==) as! Bool
    }

    return true
  }

  fileprivate typealias BinaryOperation<T> = (T, T) -> Any?

  fileprivate func performBinaryBoolOperation(_ left: Any?, _ right: Any?, _ op: String, _ f: BinaryOperation<Bool>) throws -> Any? {
    let left = try self.checkBoolOperand(left, op)
    let right = try self.checkBoolOperand(right, op)
    return f(left, right)
  }

  fileprivate func performBinaryNumberOperation(_ left: Any?, _ right: Any?, _ op: String, _ f: BinaryOperation<Double>) throws -> Any? {
    let left = try self.checkNumberOperand(left, op)
    let right = try self.checkNumberOperand(right, op)
    return f(left, right)
  }

  fileprivate func performBinaryStringOperation(_ left: Any?, _ right: Any?, _ op: String, _ f: BinaryOperation<String>) throws -> Any? {
    let left = try self.checkStringOperand(left, op)
    let right = try self.checkStringOperand(right, op)
    return f(left, right)
  }
}
