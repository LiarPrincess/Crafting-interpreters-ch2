// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

enum ScannerErrorType: Error, CustomStringConvertible {
  case unterminatedString
  case invalidCharacter(char: UnicodeScalar)

  var description: String {
    switch self {
    case .unterminatedString: return "String does not terminate"
    case .invalidCharacter(let char): return "Invalid character \(char) in source file"
    }
  }
}

struct ScannerError: CustomStringConvertible {
  let error: ScannerErrorType
  let range: SourceRange

  var description: String {
    return "\(self.range) \(self.error)"
  }
}
