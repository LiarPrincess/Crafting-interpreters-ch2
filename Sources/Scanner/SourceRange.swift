// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

struct SourceLocation: CustomStringConvertible {
  let line: Int
  let column: Int

  var description: String {
    return "[\(line):\(column)]"
  }

  static var tmp: SourceLocation {
    return SourceLocation(line: 0, column: 1)
  }
}

struct SourceRange: CustomStringConvertible {
  let start: SourceLocation
  let end:   SourceLocation

  var description: String {
    let equalLine = start.line == end.line
    let equalColumn = start.column == end.column
    return equalLine && equalColumn ? "[\(self.start.line):\(self.start.column)]" :
           equalLine                ? "[\(self.start.line):\(self.start.column)-\(self.end.column)]" :
           "[\(self.start.line):\(self.start.column)-\(self.end.line):\(self.end.column)]"
  }
}
