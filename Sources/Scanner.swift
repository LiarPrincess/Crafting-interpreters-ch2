// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

class Scanner {

  private var tokens: [Token] = []
  private let source: [Character]

  private var start   = 0
  private var current = 0

  private var line   = 1
  private var column = 0

  private var location: SourceLocation {
    return SourceLocation(line: self.line, column: self.column)
  }

  init(_ source: String) {
    self.source = Array(source)
  }

  func scanTokens() -> [Token] {
    self.tokens = []

    while (!self.isAtEnd) {
      // We are at the beginning of the next lexeme
      self.start = self.current
      self.scanToken()
    }

    self.addToken(type: .eof)
    return self.tokens
  }

  private func scanToken() {
    let c = self.advance()
    switch c {
    case "(": self.addToken(type: .leftParen)
    case ")": self.addToken(type: .rightParen)
    case "{": self.addToken(type: .leftBrace)
    case "}": self.addToken(type: .rightBrace)
    case ",": self.addToken(type: .comma)
    case ".": self.addToken(type: .dot)
    case "-": self.addToken(type: .minus)
    case "+": self.addToken(type: .plus)
    case ";": self.addToken(type: .semicolon)
    case "*": self.addToken(type: .star)

    case "!": self.addToken(type: self.advanceIf("=") ? .bangEqual : .bang)
    case "=": self.addToken(type: self.advanceIf("=") ? .equalEqual : .equal)
    case "<": self.addToken(type: self.advanceIf("=") ? .lessEqual : .less)
    case ">": self.addToken(type: self.advanceIf("=") ? .greaterEqual : .greater)

    case "/":
      if self.advanceIf("/") {
        // A comment goes until the end of the line
        while (self.peek() != "\n" && !self.isAtEnd) {
          self.advance()
        }
      }
      else { self.addToken(type: .slash) }

    case _ where c.isNewline:
      self.line += 1
      self.column = 0
    case _ where c.isWhitespace: break

    case "\"": self.string()
    case _ where self.isDigit(c): self.number()
    case _ where self.isAlpha(c): self.identifier()

    default:
      Lox.error(location: self.location, message: "Unexpected character: \"\(c)\".")
    }

    let tokenLength = self.current - self.start
    self.column += tokenLength
  }

  // MARK: - Traversal

  private var isAtEnd: Bool {
    return current >= self.source.count
  }

  @discardableResult
  private func advance() -> Character {
    let char = self.peek()
    self.current += 1
    return char
  }

  private func advanceIf(_ expected: Character) -> Bool {
    if self.isAtEnd { return false }

    let char = self.characterAt(self.current)
    if char != expected { return false }

    self.current += 1
    return true
  }

  private func peek() -> Character {
    return self.characterAt(self.current)
  }

  private func peekNext() -> Character {
    return self.characterAt(self.current + 1)
  }

  private func characterAt(_ index: Int) -> Character {
    let inBounds = index < self.source.count
    return inBounds ? self.source[index] : "\0"
  }

  private func charactersIn(_ range: Range<Int>) -> ArraySlice<Character> {
   return self.source[range]
  }

  // MARK: - Character types

  private func isDigit(_ char: Character) -> Bool {
    return char >= "0" && char <= "9"
  }

  private func isAlpha(_ char: Character) -> Bool {
    return (char >= "a" && char <= "z")
        || (char >= "A" && char <= "Z")
        || char == "_"
  }

  private func isAlphaNumeric(_ char: Character) -> Bool {
    return self.isAlpha(char) || self.isDigit(char)
  }

  // MARK: - Reading

  private func string() {
    while self.peek() != "\"" && !self.isAtEnd {
      if self.peek() == "\n" {
        self.line += 1
        self.column = 0
      }
      self.advance()
    }

    // Unterminated string
    if self.isAtEnd {
      Lox.error(location: self.location, message: "Unterminated string.")
      return
    }

    // The closing "
    self.advance()

    // Trim the surrounding quotes
    let value = self.charactersIn((self.start + 1)..<(self.current - 1))
    self.addToken(type: .string(String(value)))
  }

  private func number() {
    while self.isDigit(self.peek()) {
      self.advance()
    }

  // Look for a fractional part
  if self.peek() == "." && self.isDigit(self.peekNext()) {
    // Consume the "."
    advance()

    while (self.isDigit(self.peek())) {
      self.advance()
    }
  }

    let valueString = self.charactersIn(self.start..<self.current)
    let value = Double(String(valueString))!
    self.addToken(type: .number(value))
  }

  private func identifier() {
    while (self.isAlphaNumeric(self.peek())) {
      self.advance()
    }

    // See if the identifier is a reserved word
    let text = String(self.charactersIn(self.start..<self.current))

    if let type = keywords[text] {
      self.addToken(type: type)
    }
    else { self.addToken(type: .identifier(text)) }
  }

  private let keywords: [String:TokenType] = {
    var result = Dictionary<String, TokenType>(minimumCapacity: 20)
    result["and"]    = .and
    result["class"]  = .class
    result["else"]   = .else
    result["false"]  = .false
    result["for"]    = .for
    result["fun"]    = .fun
    result["if"]     = .if
    result["nil"]    = .nil
    result["or"]     = .or
    result["print"]  = .print
    result["return"] = .return
    result["super"]  = .super
    result["this"]   = .this
    result["true"]   = .true
    result["var"]    = .var
    result["while"]  = .while
    return result
  }()

  // MARK: - Add token

  private func addToken(type: TokenType) {
    self.tokens.append(Token(type: type, location: self.location))
  }
}
