// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

enum Operator: String, CustomStringConvertible {
  case plus = "+"
  case minus = "-"
  case star = "*"
  case slash = "/"

  case bang = "!"
  case bangEqual = "!="
  case equal = "="
  case equalEqual = "=="

  case less = "<"
  case lessEqual = "<="
  case greater = ">"
  case greaterEqual = ">="

  case and = "&&"
  case or = "||"

  var description: String {
    return self.rawValue
  }

  static func fromToken(_ tokenType: TokenType) -> Operator? {
    switch tokenType {
    case .plus:  return .plus
    case .minus: return .minus
    case .star:  return .star
    case .slash: return .slash

    case .bang:       return .bang
    case .bangEqual:  return .bangEqual
    case .equal:      return .equal
    case .equalEqual: return .equalEqual

    case .less:         return .less
    case .lessEqual:    return .lessEqual
    case .greater:      return .greater
    case .greaterEqual: return .greaterEqual

    case .and: return .and
    case .or:  return .or

    default:
      return nil
    }
  }
}
