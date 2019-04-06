// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

// swiftlint:disable function_body_length

private func writeFileContent(_ baseClassName: String, _ templates: [Template], to path: String) {
  freopen(path, "w", stdout)
  defer { fclose(stdout) }

  printLicense()
  printSwiftLintDisable()
  printVisitorProtocol(baseClassName, templates)
  printBaseClass(baseClassName)
  printTypes(baseClassName, templates)
}

func writeExpr(to path: String) {
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
    ]),
    Template(name: "Get", fields: [
      Field(name: "object", type: "Expr"),
      Field(name: "name",   type: "String")
    ])
  ]

  writeFileContent("Expr", templates, to: path)
}

func writeStmt(to path: String) {
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
    ]),
    Template(name: "Class", fields: [
      Field(name: "name", type: "String"),
      Field(name: "methods", type: "[FunctionStmt]")
    ])
  ]

  writeFileContent("Stmt", templates, to: path)
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
