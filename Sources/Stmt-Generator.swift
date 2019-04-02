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

private let protocolName = "Stmt"

private let templates = [
  Template(name: "Print", fields: [
    Field(name: "expr", type: "Expr")
  ]),
  Template(name: "Expression", fields: [
    Field(name: "expr", type: "Expr")
  ])
]

private func defineLicense() {
  print("// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.")
  print("// If a copy of the MPL was not distributed with this file,")
  print("// You can obtain one at http://mozilla.org/MPL/2.0/.")
  print("")
}

private var protocolNameLowercase: String {
  return protocolName.lowercased()
}

private var visitorName: String {
  return "\(protocolName)Visitor"
}

private func getType(_ template: Template) -> String {
  return "\(template.name)\(protocolName)"
}

private func defineVisitorProtocol() {
  print("protocol \(visitorName) {")

  for template in templates {
    let type = getType(template)
    print("  func visit\(type)(_ \(protocolNameLowercase): \(type)) throws")
  }
  print("}")
  print("")

  print("extension \(visitorName) {")
  print("  func visit(_ \(protocolNameLowercase): \(protocolName)) throws {")
  print("    switch \(protocolNameLowercase) {")
  for template in templates {
    let type = getType(template)
    print("    case let \(protocolNameLowercase) as \(type):")
    print("      try self.visit\(type)(\(protocolNameLowercase))")
  }
  print("    default:")
  print("      fatalError(\"Unknown \(protocolNameLowercase) \\(\(protocolNameLowercase))\")")
  print("    }")
  print("  }")
  print("}")
  print("")
}

private func defineBaseProtcol() {
  print("protocol \(protocolName) {")
  print("  func accept(_ visitor: \(visitorName)) throws")
  print("}")
  print("")
}

private func defineTypes() {
  for template in templates {
    let type = getType(template)
    print("struct \(type): \(protocolName) {")

    for field in template.fields {
      print("  let \(field.name): \(field.type)")
    }
    print("")

    print("  func accept(_ visitor: \(visitorName)) throws {")
    print("    try visitor.visit\(type)(self)")
    print("  }")

    print("}")
    print("")
  }
}

func defineStmt() {
  defineLicense()
  defineVisitorProtocol()
  defineBaseProtcol()
  defineTypes()
}
