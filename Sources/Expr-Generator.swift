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

private let protocolName = "Expr"
private let templates = [
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
    Field(name: "op",    type: "Token"),
    Field(name: "right", type: "Expr")
  ]),
  Template(name: "Binary", fields: [
    Field(name: "op",    type: "Token"),
    Field(name: "left",  type: "Expr"),
    Field(name: "right", type: "Expr"),
  ]),
  Template(name: "Grouping", fields: [
    Field(name: "expr", type: "Expr")
  ])
]

private func getType(_ template: Template) -> String {
  return "\(template.name)\(protocolName)"
}

private func defineVisitorProtocol() {
  print("protocol \(protocolName)Visitor {")
  print("  associatedtype Result")
  print("")
  for template in templates {
    let type = getType(template)
    print("  @discardableResult func visit\(type)(_ expr: \(type)) throws -> Result")
  }
  print("}")
  print("")

  print("extension ExprVisitor {")
  print("  ")
  print("  func visit(_ expr: Expr) throws -> Result {")
  print("    switch expr {")
  for template in templates {
    let type = getType(template)
    print("    case let expr as \(type):")
    print("      return try self.visit\(type)(expr)")
  }
  print("    default:")
  print("      fatalError(\"Unknown expr \\(expr)\")")
  print("    }")
  print("  }")
  print("}")
  print("")
}

func defineBaseProtcol() {
  print("protocol \(protocolName) {")
  print("func accept<V: ExprVisitor, R>(_ visitor: V) throws -> R where R == V.Result")
  print("}")
  print("")
}

func defineTypes() {
  for template in templates {
    let type = getType(template)
    print("struct \(type): \(protocolName) {")

    for field in template.fields {
      print("  let \(field.name): \(field.type)")
    }
    print("")

    print("  func accept<V: ExprVisitor, R>(_ visitor: V) throws -> R where R == V.Result {")
    print("    return try visitor.visit\(type)(self)")
    print("  }")

    print("}")
    print("")
  }
}

func defineAst() {
  print("// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.")
  print("// If a copy of the MPL was not distributed with this file,")
  print("// You can obtain one at http://mozilla.org/MPL/2.0/.")
  print("")

  defineVisitorProtocol()
  defineBaseProtcol()
  defineTypes()
}
