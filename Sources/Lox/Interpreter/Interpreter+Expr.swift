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
      let right = try self.numberOrThrow(right, "-")
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
      if self.isNumber(left) && self.isNumber(right) {
        return try self.performNumberOperation(left, right, "+", +)
      }
      if self.isString(left) || self.isString(right) {
        if left == nil || right == nil { return nil }
        return try self.performStringOperation(String(describing: left!), String(describing: right!), "+", +)
      }

      throw RuntimeError.invalidOperandTypes(op: "+", leftType: self.getType(left), rightType: self.getType(right))

    case .minus: return try self.performNumberOperation(left, right, "-", -)
    case .slash: return try self.performNumberOperation(left, right, "/", /)
    case .star:  return try self.performNumberOperation(left, right, "*", *)

    case .greater:      return try self.performNumberOperation(left, right, ">", >)
    case .greaterEqual: return try self.performNumberOperation(left, right, ">=", >=)
    case .less:         return try self.performNumberOperation(left, right, "<", <)
    case .lessEqual:    return try self.performNumberOperation(left, right, "<=", <=)

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
    return try self.lookUpVariable(expr.name, expr)
  }

  private func lookUpVariable(_ name: String, _ expr: Expr) throws -> Any? {
    if let depth = locals[expr] {
      return try self.environment.get(name, at: depth)
    }
    else {
      return try self.globals.get(name)
    }
  }

  func visitAssignExpr(_ expr: AssignExpr) throws -> Any? {
    let value = try self.evaluate(expr.value)

    if let depth = self.locals[expr] {
      try self.environment.assign(expr.name, value, at: depth)
    }
    else {
      try self.globals.assign(expr.name, value)
    }

    return value
  }

  func visitCallExpr(_ expr: CallExpr) throws -> Any? {
    let calee = try self.evaluate(expr.calee)

    var arguments = [Any?]()
    for arg in expr.arguments {
      arguments.append(try self.evaluate(arg))
    }

    guard let function = calee as? Callable else {
      throw RuntimeError.notCallable(type: self.getType(calee))
    }

    let argCount = arguments.count
    if function.arity != argCount {
      throw RuntimeError.invalidArgumentCount(expected: function.arity, actuall: argCount)
    }

    return try function.call(self, arguments)
  }
}

// MARK: - Binary operations

// swiftlint:disable force_cast

extension Interpreter {

  private func isEqual(_ left: Any?, _ right: Any?) throws -> Bool {
    if left == nil && right == nil { return true }
    if left == nil || right == nil { return false }

    if let left = left as? Bool, let right = right as? Bool {
      return left == right
    }

    if let left = left as? Double, let right = right as? Double {
      return left == right
    }

    if let left = left as? String, let right = right as? String {
      return left == right
    }

    return true
  }

  private func isBool(_ operand: Any?) -> Bool {
    return operand is Bool
  }

  private func isNumber(_ operand: Any?) -> Bool {
    return operand is Double
  }

  private func isString(_ operand: Any?) -> Bool {
    return operand is String
  }

  private func boolOrThrow(_ operand: Any?, _ op: String) throws -> Bool {
    guard self.isBool(operand) else {
      throw RuntimeError.invalidOperandType(op: op, type: self.getType(operand))
    }

    return operand as! Bool
  }

  private func numberOrThrow(_ operand: Any?, _ op: String) throws -> Double {
    guard self.isNumber(operand) else {
      throw RuntimeError.invalidOperandType(op: op, type: self.getType(operand))
    }

    return operand as! Double
  }

  private func stringOrThrow(_ operand: Any?, _ op: String) throws -> String {
    guard self.isString(operand) else {
      throw RuntimeError.invalidOperandType(op: op, type: self.getType(operand))
    }

    return operand as! String
  }

  private typealias BinaryOperation<T> = (T, T) -> Any?

  private func performBoolOperation(_ left: Any?, _ right: Any?, _ op: String, _ f: BinaryOperation<Bool>) throws -> Any? {
    let left = try self.boolOrThrow(left, op)
    let right = try self.boolOrThrow(right, op)
    return f(left, right)
  }

  private func performNumberOperation(_ left: Any?, _ right: Any?, _ op: String, _ f: BinaryOperation<Double>) throws -> Any? {
    let left = try self.numberOrThrow(left, op)
    let right = try self.numberOrThrow(right, op)
    return f(left, right)
  }

  private func performStringOperation(_ left: Any?, _ right: Any?, _ op: String, _ f: BinaryOperation<String>) throws -> Any? {
    let left = try self.stringOrThrow(left, op)
    let right = try self.stringOrThrow(right, op)
    return f(left, right)
  }
}
