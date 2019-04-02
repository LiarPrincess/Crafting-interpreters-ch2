// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

protocol ExprVisitor {
  associatedtype Result

  @discardableResult func visitBoolExpr(_ expr: BoolExpr) throws -> Result
  @discardableResult func visitNumberExpr(_ expr: NumberExpr) throws -> Result
  @discardableResult func visitStringExpr(_ expr: StringExpr) throws -> Result
  @discardableResult func visitNilExpr(_ expr: NilExpr) throws -> Result
  @discardableResult func visitUnaryExpr(_ expr: UnaryExpr) throws -> Result
  @discardableResult func visitBinaryExpr(_ expr: BinaryExpr) throws -> Result
  @discardableResult func visitGroupingExpr(_ expr: GroupingExpr) throws -> Result
}

extension ExprVisitor {
  func visit(_ expr: Expr) throws -> Result {
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
    case let expr as GroupingExpr:
      return try self.visitGroupingExpr(expr)
    default:
      fatalError("Unknown expr \(expr)")
    }
  }
}

protocol Expr {
  func accept<V: ExprVisitor, R>(_ visitor: V) throws -> R where R == V.Result
}

struct BoolExpr: Expr {
  let value: Bool

  func accept<V: ExprVisitor, R>(_ visitor: V) throws -> R where R == V.Result {
    return try visitor.visitBoolExpr(self)
  }
}

struct NumberExpr: Expr {
  let value: Double

  func accept<V: ExprVisitor, R>(_ visitor: V) throws -> R where R == V.Result {
    return try visitor.visitNumberExpr(self)
  }
}

struct StringExpr: Expr {
  let value: String

  func accept<V: ExprVisitor, R>(_ visitor: V) throws -> R where R == V.Result {
    return try visitor.visitStringExpr(self)
  }
}

struct NilExpr: Expr {

  func accept<V: ExprVisitor, R>(_ visitor: V) throws -> R where R == V.Result {
    return try visitor.visitNilExpr(self)
  }
}

struct UnaryExpr: Expr {
  let op: Token
  let right: Expr

  func accept<V: ExprVisitor, R>(_ visitor: V) throws -> R where R == V.Result {
    return try visitor.visitUnaryExpr(self)
  }
}

struct BinaryExpr: Expr {
  let op: Token
  let left: Expr
  let right: Expr

  func accept<V: ExprVisitor, R>(_ visitor: V) throws -> R where R == V.Result {
    return try visitor.visitBinaryExpr(self)
  }
}

struct GroupingExpr: Expr {
  let expr: Expr

  func accept<V: ExprVisitor, R>(_ visitor: V) throws -> R where R == V.Result {
    return try visitor.visitGroupingExpr(self)
  }
}
