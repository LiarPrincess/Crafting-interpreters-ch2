// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

enum RuntimeErrorType: CustomStringConvertible {
  case invalidOperandType(String)

  var description: String {
    switch self {
    case let .invalidOperandType(type): return "Invalid operand type: \(type)."
    }
  }
}

struct RuntimeError: Error {
  let token: Token
  let type:  RuntimeErrorType
}

class Interpreter: ExprVisitor {

  typealias Result = Any?

  func interpret(_ expr: Expr) -> Any? {
    do {
      return try self.visit(expr)
    }
    catch let error as RuntimeError {
      let location = error.token.location
      let message = String(describing: error.type)
      Lox.runtimeError(location: location, message: message)
      return nil
    }
    catch {
      fatalError("Unknown error")
    }
  }

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

    switch expr.op.type {
    case .minus:
      let right = try self.checkNumberOperand(expr.op, right)
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
    let token = expr.op
    let left = try self.evaluate(expr.left)
    let right = try self.evaluate(expr.right)

    switch token.type {
    case .plus:
      if self.isNumberOperand(left) && self.isNumberOperand(right) {
        return try self.performBinaryNumberOperation(token, left, right, +)
      }
      if self.isStringOperand(left) && self.isStringOperand(right) {
        return try self.performBinaryStringOperation(token, left, right, +)
      }
      if self.isStringOperand(left) || self.isStringOperand(right) {
        if left == nil || right == nil { return nil }
        return try self.performBinaryStringOperation(token, String(describing: left!), String(describing: right!), +)
      }

      throw RuntimeError(token: token, type: .invalidOperandType("\(left.self.debugDescription) and \(right.self.debugDescription)"))

    case .minus: return try self.performBinaryNumberOperation(token, left, right, -)
    case .slash: return try self.performBinaryNumberOperation(token, left, right, /)
    case .star:  return try self.performBinaryNumberOperation(token, left, right, *)

    case .greater:      return try self.performBinaryNumberOperation(token, left, right, >)
    case .greaterEqual: return try self.performBinaryNumberOperation(token, left, right, >=)
    case .less:         return try self.performBinaryNumberOperation(token, left, right, <)
    case .lessEqual:    return try self.performBinaryNumberOperation(token, left, right, <=)

    case .equalEqual: return try  self.isEqual(token, left, right)
    case .bangEqual:  return try !self.isEqual(token, left, right)

    default:
      return nil
    }
  }

  private typealias BinaryOperation<T> = (T, T) -> Any?

  private func performBinaryBoolOperation(_ token: Token, _ left: Any?, _ right: Any?, _ op: BinaryOperation<Bool>) throws -> Any? {
    let left = try self.checkBoolOperand(token, left)
    let right = try self.checkBoolOperand(token, right)
    return op(left, right)
  }

  private func performBinaryNumberOperation(_ token: Token, _ left: Any?, _ right: Any?, _ op: BinaryOperation<Double>) throws -> Any? {
    let left = try self.checkNumberOperand(token, left)
    let right = try self.checkNumberOperand(token, right)
    return op(left, right)
  }

  private func performBinaryStringOperation(_ token: Token, _ left: Any?, _ right: Any?, _ op: BinaryOperation<String>) throws -> Any? {
    let left = try self.checkStringOperand(token, left)
    let right = try self.checkStringOperand(token, right)
    return op(left, right)
  }

  private func isEqual(_ token: Token, _ left: Any?, _ right: Any?) throws -> Bool {
    if left == nil && right == nil { return true }
    if left == nil || right == nil { return false }

    if self.isBoolOperand(left) && self.isBoolOperand(right) {
      return try self.performBinaryBoolOperation(token, left, right, ==) as! Bool
    }

    if self.isNumberOperand(left) && self.isNumberOperand(right) {
      return try self.performBinaryNumberOperation(token, left, right, ==) as! Bool
    }

    if self.isStringOperand(left) && self.isStringOperand(right) {
      return try self.performBinaryStringOperation(token, left, right, ==) as! Bool
    }

    return true
  }

  func visitGroupingExpr(_ expr: GroupingExpr) throws -> Any? {
    return try self.evaluate(expr.expr)
  }

  private func evaluate(_ expr: Expr) throws -> Any? {
    return try expr.accept(self)
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

  private func checkBoolOperand(_ token: Token, _ operand: Any?) throws -> Bool {
    guard self.isBoolOperand(operand) else {
      throw RuntimeError(token: token, type: .invalidOperandType(operand.self.debugDescription))
    }

    return operand as! Bool
  }

  private func checkNumberOperand(_ token: Token, _ operand: Any?) throws -> Double {
    guard self.isNumberOperand(operand) else {
      throw RuntimeError(token: token, type: .invalidOperandType(operand.self.debugDescription))
    }

    return operand as! Double
  }

  private func checkStringOperand(_ token: Token, _ operand: Any?) throws -> String {
    guard self.isStringOperand(operand) else {
      throw RuntimeError(token: token, type: .invalidOperandType(operand.self.debugDescription))
    }

    return operand as! String
  }
}
