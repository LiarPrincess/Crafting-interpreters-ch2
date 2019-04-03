// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

struct SourceLocation: CustomStringConvertible {
  let line: Int
  let column: Int

  var description: String {
    return "[\(line),\(column)]"
  }

  static var tmp: SourceLocation {
    return SourceLocation(line: 0, column: 0)
  }
}
