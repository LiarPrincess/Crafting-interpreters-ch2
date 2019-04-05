// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

enum VariableState {

  /// Variable was declared but not yet initialized
  case declared

  /// Variable was declared and initialized
  case initialized
}

class VariableInfo {
  var state: VariableState
  var isUsed = false

  init(state: VariableState) {
    self.state = state
  }
}

class ScopeInfo {
  var variables = [String:VariableInfo]()
}
