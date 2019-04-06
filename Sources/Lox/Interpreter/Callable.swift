// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

struct Return: Error {
  let value: Any?
}

protocol Callable {
  var arity: Int { get }
  func call(_ interpreter: Interpreter, _ arguments: [Any?]) throws -> Any?
}

struct ClockCallable: Callable {

  let arity = 0

  func call(_ interpreter: Interpreter, _ arguments: [Any?]) throws -> Any? {
    let now = Date()
    return now.timeIntervalSince1970
  }
}
