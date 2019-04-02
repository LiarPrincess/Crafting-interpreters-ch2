// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

let stdout = FileHandle.standardOutput
let stderr = FileHandle.standardError

class Lox {

  private static let interpreter = Interpreter()

  private static var hadError = false
  private static var hadRuntimeError = false

  static func main(_ args: [String]) throws {
    switch args.count {
    case 0:
      runPrompt()
      exit(EXIT_SUCCESS)
    case 1:
      try runFile(args[0])
      exit(EXIT_SUCCESS)
    default:
      write(stdout, message: "Usage: Lox [script]\n")
      exit(EXIT_FAILURE)
    }
  }

  // MARK: - Run

  private static func runFile(_ path: String) throws {
    let source = try String(contentsOfFile: path, encoding: .utf8)
    run(source)

    if hadError || hadRuntimeError { exit(EXIT_FAILURE) }
  }

  private static func runPrompt() {
    while true {
      write(stdout, message: "> ")
      guard let line = readLine(strippingNewline: true) else { return }
      run(line)
      hadError = false
    }
  }

  private static func run(_ source: String) {
    print("Scanning -> Tokens")
    let scanner = Scanner(source)
    let tokens = scanner.scanTokens()

    for token in tokens {
      print(token)
    }
    print("")

    print("Parsing -> AST")
    let parser = Parser(tokens)
    guard let statements = parser.parse() else {
      return
    }

    let printer = AstPrinter()
    for statement in statements {
      print(try! printer.visit(statement))
    }
    print("")

    print("Result")
    interpreter.interpret(statements)
  }

  // MARK: - Errors

  static func error(location: SourceLocation, message: String) {
    write(stderr, message: "\(location) Error: \(message)\n")
    hadError = true
  }

  static func runtimeError(location: SourceLocation, message: String) {
    write(stderr, message: "\(location) Runtime error: \(message)\n")
    hadRuntimeError = true
  }

  // MARK: - Helpers

  private static func write(_ file: FileHandle, message: String) {
    let messageLine = message
    let data = messageLine.data(using: .utf8)!
    file.write(data)
  }

  // MARK: - Private ctor

  private init() {}
}
