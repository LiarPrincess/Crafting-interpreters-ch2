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

private func getVisitorName(_ protocolName: String) -> String {
  return "\(protocolName)Visitor"
}

private func getTypeName(_ protocolName: String, _ template: Template) -> String {
  return "\(template.name)\(protocolName)"
}

private func getVisitorResultName(_ protocolName: String) -> String {
  return "\(protocolName)Result" 
}

private func defineVisitorProtocol(_ protocolName: String, _ templates: [Template]) {
  let visitorName = getVisitorName(protocolName)
  let visitorResult = getVisitorResultName(protocolName)
  let protocolNameLowercase = protocolName.lowercased()

  print("protocol \(visitorName) {")
  print("  associatedtype \(visitorResult)")
  print("")

  for template in templates {
    let type = getTypeName(protocolName, template)
    print("  @discardableResult func visit\(type)(_ \(protocolNameLowercase): \(type)) throws -> \(visitorResult)")
  }
  print("}")
  print("")

  print("extension \(visitorName) {")
  print("  func visit(_ \(protocolNameLowercase): \(protocolName)) throws -> \(visitorResult) {")
  print("    switch \(protocolNameLowercase) {")
  for template in templates {
    let type = getTypeName(protocolName, template)
    print("    case let \(protocolNameLowercase) as \(type):")
    print("      return try self.visit\(type)(\(protocolNameLowercase))")
  }
  print("    default:")
  print("      fatalError(\"Unknown \(protocolNameLowercase) \\(\(protocolNameLowercase))\")")
  print("    }")
  print("  }")
  print("}")
  print("")
}

private func defineBaseProtcol(_ protocolName: String) {
  let visitorName = getVisitorName(protocolName)
  let visitorResult = getVisitorResultName(protocolName)

  print("protocol \(protocolName) {")
  print("  func accept<V: \(visitorName), R>(_ visitor: V) throws -> R where R == V.\(visitorResult)")
  print("}")
  print("")
}

private func defineTypes(_ protocolName: String, _ templates: [Template]) {
  let visitorName = getVisitorName(protocolName)
  let visitorResult = getVisitorResultName(protocolName)

  for template in templates {
    let type = getTypeName(protocolName, template)
    print("struct \(type): \(protocolName) {")

    for field in template.fields {
      print("  let \(field.name): \(field.type)")
    }
    print("")

    print("  func accept<V: \(visitorName), R>(_ visitor: V) throws -> R where R == V.\(visitorResult) {")
    print("    return try visitor.visit\(type)(self)")
    print("  }")

    print("}")
    print("")
  }
}

private func define(_ protocolName: String, _ templates: [Template]) {
  defineLicense()
  defineVisitorProtocol(protocolName, templates)
  defineBaseProtcol(protocolName)
  defineTypes(protocolName, templates)
}

func defineExpr() {
  let protocolName = "Expr"

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
    ]),

    Template(name: "Variable", fields: [
      Field(name: "name", type: "String")
    ])
  ]

  define(protocolName, templates)
}

func defineStmt() {
  let protocolName = "Stmt"

  let templates = [
    Template(name: "Print", fields: [
      Field(name: "expr", type: "Expr")
    ]),
    Template(name: "Expression", fields: [
      Field(name: "expr", type: "Expr")
    ]),
    Template(name: "Var", fields: [
      Field(name: "name", type: "String"),
      Field(name: "initializer", type: "Expr?")
    ])
  ]

  define(protocolName, templates)
}
