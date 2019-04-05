// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

private let stdout = FileHandle.standardOutput
private let stderr = FileHandle.standardError

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
    let scanResult = scanner.scanTokens()

    scanResult.tokens.forEach { print($0) }
    guard scanResult.errors.isEmpty else {
      scanResult.errors.forEach { print($0) }
      return
    }

    print("")

    print("Parsing -> AST")
    let parser: ParserType = Parser(scanResult.tokens)
    guard let statements = parser.parse() else {
      return
    }

    let printer = AstPrinter()
    for statement in statements {
      // swiftlint:disable:next force_try
      print(try! printer.visit(statement))
    }
    print("")

    if hadError {
      return
    }

    print("Resolver")
    let resolver = Resolver(self.interpreter)
    do {
      try resolver.resolve(statements)
    } catch let error {
      print(error)
      return
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
