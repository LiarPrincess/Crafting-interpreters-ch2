// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

private struct Field {
  let name: String
  let type: String
}

private struct Template {
  let name:   String
  let fields: [Field]
}

private func defineLicense() {
  print("// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.")
  print("// If a copy of the MPL was not distributed with this file,")
  print("// You can obtain one at http://mozilla.org/MPL/2.0/.")
  print("")
}

private func getVisitorName(_ baseClassName: String) -> String {
  return "\(baseClassName)Visitor"
}

private func getTypeName(_ baseClassName: String, _ template: Template) -> String {
  return "\(template.name)\(baseClassName)"
}

private func getVisitorResultName(_ baseClassName: String) -> String {
  return "\(baseClassName)Result"
}

private func defineVisitorProtocol(_ baseClassName: String, _ templates: [Template]) {
  let visitorName = getVisitorName(baseClassName)
  let visitorResult = getVisitorResultName(baseClassName)
  let baseClassNameLowercase = baseClassName.lowercased()

  print("protocol \(visitorName) {")
  print("  associatedtype \(visitorResult)")
  print("")

  for template in templates {
    let type = getTypeName(baseClassName, template)
    print("  @discardableResult")
    print("  func visit\(type)(_ \(baseClassNameLowercase): \(type)) throws -> \(visitorResult)")
  }
  print("}")
  print("")

  print("extension \(visitorName) {")
  print("  func visit(_ \(baseClassNameLowercase): \(baseClassName)) throws -> \(visitorResult) {")
  print("    switch \(baseClassNameLowercase) {")
  for template in templates {
    let type = getTypeName(baseClassName, template)
    print("    case let \(baseClassNameLowercase) as \(type):")
    print("      return try self.visit\(type)(\(baseClassNameLowercase))")
  }
  print("    default:")
  print("      fatalError(\"Unknown \(baseClassNameLowercase) \\(\(baseClassNameLowercase))\")")
  print("    }")
  print("  }")
  print("}")
  print("")
}

private func defineBaseClass(_ baseClassName: String) {
  let visitorName = getVisitorName(baseClassName)
  let visitorResult = getVisitorResultName(baseClassName)

  print("class \(baseClassName): Equatable, Hashable {")
  print("")

  print("  func accept<V: \(visitorName), R>(_ visitor: V) throws -> R where R == V.\(visitorResult) {")
  print("    fatalError(\"Accept metod should be overriden in subclass\")")
  print("  }")
  print("")

  print("  static func == (lhs: \(baseClassName), rhs: \(baseClassName)) -> Bool {")
  print("    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)")
  print("  }")

  print("  func hash(into hasher: inout Hasher) {")
  print("    hasher.combine(ObjectIdentifier(self).hashValue)")
  print("  }")

  print("}")
  print("")
}

private func defineTypes(_ baseClassName: String, _ templates: [Template]) {
  let visitorName = getVisitorName(baseClassName)
  let visitorResult = getVisitorResultName(baseClassName)

  for template in templates {
    let type = getTypeName(baseClassName, template)
    print("class \(type): \(baseClassName) {")

    for field in template.fields {
      print("  let \(field.name): \(field.type)")
    }
    print("")

    if !template.fields.isEmpty {
      let ctorParameters = template.fields.map { "\($0.name): \($0.type)" }.joined(separator: ", ")
      print("  init(\(ctorParameters)) {")
      for field in template.fields {
        print("    self.\(field.name) = \(field.name)")
      }
      print("  }")
      print("")
    }

    print("  override func accept<V: \(visitorName), R>(_ visitor: V) throws -> R where R == V.\(visitorResult) {")
    print("    return try visitor.visit\(type)(self)")
    print("  }")

    print("}")
    print("")
  }
}

private func define(_ baseClassName: String, _ templates: [Template], to path: String) {
  freopen(path, "w", stdout)
  defer { fclose(stdout) }

  defineLicense()
  defineVisitorProtocol(baseClassName, templates)
  defineBaseClass(baseClassName)
  defineTypes(baseClassName, templates)
}

// swiftlint:disable:next function_body_length
func writeExpr(to path: String) {
  let baseClassName = "Expr"

  let templates = [
    Template(name: "Bool", fields: [
      Field(name: "value", type: "Bool")
    ]),
    Template(name: "Number", fields: [
      Field(name: "value", type: "Double")
    ]),
    Template(name: "String", fields: [
      Field(name: "value", type: "String")
    ]),
    Template(name: "Nil", fields: []),

    Template(name: "Unary", fields: [
      Field(name: "op",    type: "Operator"),
      Field(name: "right", type: "Expr")
    ]),
    Template(name: "Binary", fields: [
      Field(name: "op",    type: "Operator"),
      Field(name: "left",  type: "Expr"),
      Field(name: "right", type: "Expr")
    ]),
    Template(name: "Logical", fields: [
      Field(name: "op",    type: "Operator"),
      Field(name: "left",  type: "Expr"),
      Field(name: "right", type: "Expr")
    ]),
    Template(name: "Grouping", fields: [
      Field(name: "expr", type: "Expr")
    ]),

    Template(name: "Variable", fields: [
      Field(name: "name", type: "String")
    ]),
    Template(name: "Assign", fields: [
      Field(name: "name",  type: "String"),
      Field(name: "value", type: "Expr")
    ]),

    Template(name: "Call", fields: [
      Field(name: "calee",     type: "Expr"),
      Field(name: "arguments", type: "[Expr]")
    ])
  ]

  define(baseClassName, templates, to: path)
}

func writeStmt(to path: String) {
  let baseClassName = "Stmt"

  let templates = [
    Template(name: "Print", fields: [
      Field(name: "expr", type: "Expr")
    ]),
    Template(name: "Expression", fields: [
      Field(name: "expr", type: "Expr")
    ]),
    Template(name: "Var", fields: [
      Field(name: "name",        type: "String"),
      Field(name: "initializer", type: "Expr?")
    ]),
    Template(name: "Block", fields: [
      Field(name: "statements", type: "[Stmt]")
    ]),
    Template(name: "If", fields: [
      Field(name: "condition",  type: "Expr"),
      Field(name: "thenBranch", type: "Stmt"),
      Field(name: "elseBranch", type: "Stmt?")
    ]),
    Template(name: "While", fields: [
      Field(name: "condition", type: "Expr"),
      Field(name: "body",      type: "Stmt")
    ]),
    Template(name: "Function", fields: [
      Field(name: "name",       type: "String"),
      Field(name: "parameters", type: "[String]"),
      Field(name: "body",       type: "[Stmt]")
    ]),
    Template(name: "Return", fields: [
      Field(name: "value", type: "Expr?")
    ])
  ]

  define(baseClassName, templates, to: path)
}

let currentFile = URL(fileURLWithPath: #file)
let sourcesDir = currentFile.deletingLastPathComponent().deletingLastPathComponent()
let parserDir = sourcesDir.appendingPathComponent("Lox").appendingPathComponent("Parser")

let exprFile = parserDir.appendingPathComponent("Expr.swift")
let stmtFile = parserDir.appendingPathComponent("Stmt.swift")

print("Writing expr to: '\(exprFile)'")
print("Writing stmt to: '\(stmtFile)'")

writeExpr(to: exprFile.path)
writeStmt(to: stmtFile.path)
