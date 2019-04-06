// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

// swiftlint:disable superfluous_disable_command
// swiftlint:disable trailing_newline
// swiftlint:disable file_length
// swiftlint:disable function_body_length
// swiftlint:disable cyclomatic_complexity

protocol ExprVisitor {
  associatedtype ExprResult

  @discardableResult
  func visitBoolExpr(_ expr: BoolExpr) throws -> ExprResult
  @discardableResult
  func visitNumberExpr(_ expr: NumberExpr) throws -> ExprResult
  @discardableResult
  func visitStringExpr(_ expr: StringExpr) throws -> ExprResult
  @discardableResult
  func visitNilExpr(_ expr: NilExpr) throws -> ExprResult
  @discardableResult
  func visitUnaryExpr(_ expr: UnaryExpr) throws -> ExprResult
  @discardableResult
  func visitBinaryExpr(_ expr: BinaryExpr) throws -> ExprResult
  @discardableResult
  func visitLogicalExpr(_ expr: LogicalExpr) throws -> ExprResult
  @discardableResult
  func visitGroupingExpr(_ expr: GroupingExpr) throws -> ExprResult
  @discardableResult
  func visitVariableExpr(_ expr: VariableExpr) throws -> ExprResult
  @discardableResult
  func visitAssignExpr(_ expr: AssignExpr) throws -> ExprResult
  @discardableResult
  func visitCallExpr(_ expr: CallExpr) throws -> ExprResult
  @discardableResult
  func visitGetExpr(_ expr: GetExpr) throws -> ExprResult
  @discardableResult
  func visitSetExpr(_ expr: SetExpr) throws -> ExprResult
  @discardableResult
  func visitThisExpr(_ expr: ThisExpr) throws -> ExprResult
}

extension ExprVisitor {
  func visit(_ expr: Expr) throws -> ExprResult {
    switch expr {
    case let expr as BoolExpr:
      return try self.visitBoolExpr(expr)
    case let expr as NumberExpr:
      return try self.visitNumberExpr(expr)
    case let expr as StringExpr:
      return try self.visitStringExpr(expr)
    case let expr as NilExpr:
      return try self.visitNilExpr(expr)
    case let expr as UnaryExpr:
      return try self.visitUnaryExpr(expr)
    case let expr as BinaryExpr:
      return try self.visitBinaryExpr(expr)
    case let expr as LogicalExpr:
      return try self.visitLogicalExpr(expr)
    case let expr as GroupingExpr:
      return try self.visitGroupingExpr(expr)
    case let expr as VariableExpr:
      return try self.visitVariableExpr(expr)
    case let expr as AssignExpr:
      return try self.visitAssignExpr(expr)
    case let expr as CallExpr:
      return try self.visitCallExpr(expr)
    case let expr as GetExpr:
      return try self.visitGetExpr(expr)
    case let expr as SetExpr:
      return try self.visitSetExpr(expr)
    case let expr as ThisExpr:
      return try self.visitThisExpr(expr)
    default:
      fatalError("Unknown expr \(expr)")
    }
  }
}

class Expr: Equatable, Hashable {

  func accept<V: ExprVisitor, R>(_ visitor: V) throws -> R where R == V.ExprResult {
    fatalError("Accept metod should be overriden in subclass")
  }

  static func == (lhs: Expr, rhs: Expr) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
  }
  func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self).hashValue)
  }
}

class BoolExpr: Expr {
  let value: Bool

  init(value: Bool) {
    self.value = value
  }

  override func accept<V: ExprVisitor, R>(_ visitor: V) throws -> R where R == V.ExprResult {
    return try visitor.visitBoolExpr(self)
  }
}

class NumberExpr: Expr {
  let value: Double

  init(value: Double) {
    self.value = value
  }

  override func accept<V: ExprVisitor, R>(_ visitor: V) throws -> R where R == V.ExprResult {
    return try visitor.visitNumberExpr(self)
  }
}

class StringExpr: Expr {
  let value: String

  init(value: String) {
    self.value = value
  }

  override func accept<V: ExprVisitor, R>(_ visitor: V) throws -> R where R == V.ExprResult {
    return try visitor.visitStringExpr(self)
  }
}

class NilExpr: Expr {

  override func accept<V: ExprVisitor, R>(_ visitor: V) throws -> R where R == V.ExprResult {
    return try visitor.visitNilExpr(self)
  }
}

class UnaryExpr: Expr {
  let op: Operator
  let right: Expr

  init(op: Operator, right: Expr) {
    self.op = op
    self.right = right
  }

  override func accept<V: ExprVisitor, R>(_ visitor: V) throws -> R where R == V.ExprResult {
    return try visitor.visitUnaryExpr(self)
  }
}

class BinaryExpr: Expr {
  let op: Operator
  let left: Expr
  let right: Expr

  init(op: Operator, left: Expr, right: Expr) {
    self.op = op
    self.left = left
    self.right = right
  }

  override func accept<V: ExprVisitor, R>(_ visitor: V) throws -> R where R == V.ExprResult {
    return try visitor.visitBinaryExpr(self)
  }
}

class LogicalExpr: Expr {
  let op: Operator
  let left: Expr
  let right: Expr

  init(op: Operator, left: Expr, right: Expr) {
    self.op = op
    self.left = left
    self.right = right
  }

  override func accept<V: ExprVisitor, R>(_ visitor: V) throws -> R where R == V.ExprResult {
    return try visitor.visitLogicalExpr(self)
  }
}

class GroupingExpr: Expr {
  let expr: Expr

  init(expr: Expr) {
    self.expr = expr
  }

  override func accept<V: ExprVisitor, R>(_ visitor: V) throws -> R where R == V.ExprResult {
    return try visitor.visitGroupingExpr(self)
  }
}

class VariableExpr: Expr {
  let name: String

  init(name: String) {
    self.name = name
  }

  override func accept<V: ExprVisitor, R>(_ visitor: V) throws -> R where R == V.ExprResult {
    return try visitor.visitVariableExpr(self)
  }
}

class AssignExpr: Expr {
  let name: String
  let value: Expr

  init(name: String, value: Expr) {
    self.name = name
    self.value = value
  }

  override func accept<V: ExprVisitor, R>(_ visitor: V) throws -> R where R == V.ExprResult {
    return try visitor.visitAssignExpr(self)
  }
}

class CallExpr: Expr {
  let calee: Expr
  let arguments: [Expr]

  init(calee: Expr, arguments: [Expr]) {
    self.calee = calee
    self.arguments = arguments
  }

  override func accept<V: ExprVisitor, R>(_ visitor: V) throws -> R where R == V.ExprResult {
    return try visitor.visitCallExpr(self)
  }
}

class GetExpr: Expr {
  let object: Expr
  let name: String

  init(object: Expr, name: String) {
    self.object = object
    self.name = name
  }

  override func accept<V: ExprVisitor, R>(_ visitor: V) throws -> R where R == V.ExprResult {
    return try visitor.visitGetExpr(self)
  }
}

class SetExpr: Expr {
  let object: Expr
  let name: String
  let value: Expr

  init(object: Expr, name: String, value: Expr) {
    self.object = object
    self.name = name
    self.value = value
  }

  override func accept<V: ExprVisitor, R>(_ visitor: V) throws -> R where R == V.ExprResult {
    return try visitor.visitSetExpr(self)
  }
}

class ThisExpr: Expr {

  override func accept<V: ExprVisitor, R>(_ visitor: V) throws -> R where R == V.ExprResult {
    return try visitor.visitThisExpr(self)
  }
}

