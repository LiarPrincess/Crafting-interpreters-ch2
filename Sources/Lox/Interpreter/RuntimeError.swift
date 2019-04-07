// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

enum RuntimeError: Error, CustomStringConvertible {
  case undefinedVariable(name: String)
  case uninitalizedVariable(name: String)
  case invalidOperandType(op: String, type: String)
  case invalidOperandTypes(op: String, leftType: String, rightType: String)
  case notCallable(type: String)
  case invalidArgumentCount(expected: Int, actuall: Int)
  case getProperyOfNonObject
  case getUndefinedPropery(name: String)
  case setProperyOfNonObject
  case superIsNotClass

  var description: String {
    switch self {
    case let .undefinedVariable(name):
      return "Undefined variable: \(name)."
    case let .uninitalizedVariable(name):
      return "Attempt to use uninitalized variable: \(name)."
    case let .invalidOperandType(op, right):
      return "Unable to perform '\(op)' with argument of type '\(right)'."
    case let .invalidOperandTypes(op, left, right):
      return "Unable to perform '\(op)' with arguments of type '\(left)' and '\(right)'."
    case let .notCallable(typ):
      return "Object of type '\(typ)' is not callable."
    case let .invalidArgumentCount(expected, actuall):
      return "Invalid argument count, expected: \(expected), got: \(actuall)."
    case .getProperyOfNonObject:
      return "Only instances have properties."
    case let .getUndefinedPropery(name):
      return "Undefined property '\(name)'."
    case .setProperyOfNonObject:
      return "Only instances have fields."
    case .superIsNotClass:
      return "Superclass must be a class."
    }
  }
}
