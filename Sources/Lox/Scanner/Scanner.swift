// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

class Scanner {

  private let source: [UnicodeScalar]

  /// Location in the source
  private var location: SourceLocation

  /// Index of the current character
  private var sourceIndex = 0

  init(_ source: String) {
    self.source = Array(source.unicodeScalars)
    self.location = SourceLocation(line: 1, column: 0)
  }

  func scanTokens() -> ScannerResult {
    var tokens = [Token]()
    var errors = [ScannerError]()

    while tokens.last?.type != .eof {
      do {
        if let token = try self.advanceToNextToken() {
          tokens.append(token)
        }
      }
      catch let error as ScannerErrorType {
        let range = self.getErrorRange(lastToken: tokens.last)
        errors.append(ScannerError(error: error, range: range))
      }
      catch {
        fatalError("Unknown scanner error")
      }
    }

    return ScannerResult(tokens: tokens, errors: errors)
  }

  private func getErrorRange(lastToken: Token?) -> SourceRange {
    let start: SourceLocation = {
      let currentLine = self.location.line
      if let lastTokenEnd = lastToken?.range.end, lastTokenEnd.line == currentLine {
        return lastTokenEnd
      }
      return SourceLocation(line: currentLine, column: 0)
    }()

    return SourceRange(start: start, end: self.location)
  }

  // swiftlint:disable:next cyclomatic_complexity function_body_length
  private func advanceToNextToken() throws -> Token? {
    guard let char = self.advance() else {
      return self.createToken(type: .eof)
    }

    switch char {
    case "(": return self.createToken(type: .leftParen)
    case ")": return self.createToken(type: .rightParen)
    case "{": return self.createToken(type: .leftBrace)
    case "}": return self.createToken(type: .rightBrace)
    case ",": return self.createToken(type: .comma)
    case ".": return self.createToken(type: .dot)
    case "-": return self.createToken(type: .minus)
    case "+": return self.createToken(type: .plus)
    case ";": return self.createToken(type: .semicolon)
    case "*": return self.createToken(type: .star)

    case "!": return self.createToken(type: self.advanceIf("=") ? .bangEqual : .bang)
    case "=": return self.createToken(type: self.advanceIf("=") ? .equalEqual : .equal)
    case "<": return self.createToken(type: self.advanceIf("=") ? .lessEqual : .less)
    case ">": return self.createToken(type: self.advanceIf("=") ? .greaterEqual : .greater)

    case "/":
      if self.advanceIf("/") {
        // A comment goes until the end of the line
        while let char = self.peek(), char != "\n" {
          self.advance()
        }
        return nil
      }
      else { return self.createToken(type: .slash) }

    case " ", "\r", "\t", "\n":
      return nil

    case "\"":
      return try self.string()
    case _ where self.isDigit(char):
      return self.number()
    case _ where self.isAlpha(char):
      return self.identifier()

    default:
      throw ScannerErrorType.invalidCharacter(char: char)
    }
  }

  // MARK: - Traversal

  /// Start of the current token (assuming that first .advance() was called)
  private var tokenStart: Int {
    return max(0, self.sourceIndex - 1)
  }

  @discardableResult
  private func advance() -> UnicodeScalar? {
    guard let char = self.peek() else {
      return nil
    }

    if char == "\n" {
      let line = self.location.line + 1
      self.location = SourceLocation(line: line, column: 0)
    } else {
      let line = self.location.line
      let column = self.location.column + 1
      self.location = SourceLocation(line: line, column: column)
    }

    self.sourceIndex += 1
    return char
  }

  private func advanceIf(_ expected: UnicodeScalar) -> Bool {
    guard let char = self.peek() else {
      return false
    }

    if char == expected {
      self.advance()
      return true
    }

    return false
  }

  private func peek() -> UnicodeScalar? {
    return self.charAt(0)
  }

  private func peekNext() -> UnicodeScalar? {
    return self.charAt(1)
  }

  private func charAt(_ index: Int) -> UnicodeScalar? {
    assert(index >= 0, "Index cannot be negative")
    assert(index < self.source.count, "Index out of bounds")

    let characterIndex = self.sourceIndex + index
    return characterIndex < self.source.count ? self.source[characterIndex] : nil
  }

  private func charactersIn(_ range: Range<Int>) -> String {
    assert(range.startIndex >= 0, "Index cannot be negative")
    assert(range.startIndex < self.source.count, "Index out of bounds")
    assert(range.endIndex >= 0, "Index cannot be negative")
    assert(range.endIndex < self.source.count, "Index out of bounds")

    let characters = self.source[range]
    return characters.map(String.init).joined()
  }

  // MARK: - Token creation

  private func createToken(type: TokenType) -> Token {
    return self.createToken(type: type, start: self.location)
  }

  private func createToken(type: TokenType, start: SourceLocation) -> Token {
    let range = SourceRange(start: start, end: self.location)
    printDebug("Creating token: \(type)")
    return Token(type: type, range: range)
  }

  // MARK: - Character types

  private func isDigit(_ char: UnicodeScalar) -> Bool {
    return char >= "0" && char <= "9"
  }

  private func isAlpha(_ char: UnicodeScalar) -> Bool {
    return (char >= "a" && char <= "z")
        || (char >= "A" && char <= "Z")
        || char == "_"
  }

  private func isAlphaNumeric(_ char: UnicodeScalar) -> Bool {
    return self.isAlpha(char) || self.isDigit(char)
  }

  // MARK: - Reading

  private func string() throws -> Token {
    let startIndex = self.tokenStart
    let startLocation = self.location

    // advance to the end of the string
    while let char = self.peek(), char != "\"" && char != "\n" {
      self.advance()
    }

    // uterminated string
    let lastChar = self.peek()
    guard lastChar != nil && lastChar != "\n" else {
      throw ScannerErrorType.unterminatedString
    }

    // closing '"'
    self.advance()

    // remove quotation
    let value = self.charactersIn((startIndex + 1)..<(self.sourceIndex - 1))
    return self.createToken(type: .string(value), start: startLocation)
  }

  private func number() -> Token {
    let startIndex = self.tokenStart
    let startLocation = self.location

    while let char = self.peek(), self.isDigit(char) {
      self.advance()
    }

    // fractional part
    if let dot = self.peek(),
       let next = self.peekNext(),
       dot == "." && self.isDigit(next)
    {
      // consume "."
      self.advance()

      while let char = self.peek(), self.isDigit(char) {
        self.advance()
      }
    }

    let valueString = self.charactersIn(startIndex..<self.sourceIndex)
    let value = Double(String(valueString))!
    return self.createToken(type: .number(value), start: startLocation)
  }

  private func identifier() -> Token {
    let startIndex = self.tokenStart
    let startLocation = self.location

    while let char = self.peek(), self.isAlphaNumeric(char) {
      self.advance()
    }

    let text = self.charactersIn(startIndex..<self.sourceIndex)

    // is identifier is a reserved word?
    let type = keywords[text] ?? .identifier(text)
    return self.createToken(type: type, start: startLocation)
  }

  private let keywords: [String:TokenType] = ["and": .and,
                                              "class": .class,
                                              "else": .else,
                                              "false": .false,
                                              "for": .for,
                                              "fun": .fun,
                                              "if": .if,
                                              "nil": .nil,
                                              "or": .or,
                                              "print": .print,
                                              "return": .return,
                                              "super": .super,
                                              "this": .this,
                                              "true": .true,
                                              "var": .var,
                                              "while": .while]
}
