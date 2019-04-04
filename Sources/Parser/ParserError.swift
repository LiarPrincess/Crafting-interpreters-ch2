// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

enum ParseError: Error, CustomStringConvertible {
  case missingToken(String)
  case expectedExpression
  case invalidAssignment

  var description: String {
    switch self {
    case let .missingToken(token): return "Expected \(token)."
    case .expectedExpression: return "Expected expression."
    case .invalidAssignment: return "Invalid assignment target."
    }
  }
}
