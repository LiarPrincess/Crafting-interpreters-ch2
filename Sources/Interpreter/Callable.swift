// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

protocol Callable {
  var arity: Int { get }
  func call(_ interpreter: InterpreterType, _ arguments: [Any?]) -> Any?
}

struct ClockCallable: Callable {

  var arity = 0

  func call(_ interpreter: InterpreterType, _ arguments: [Any?]) -> Any? {
    let now = Date()
    return now.timeIntervalSince1970
  }
}
