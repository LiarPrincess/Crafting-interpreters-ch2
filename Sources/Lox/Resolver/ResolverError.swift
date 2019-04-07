// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

enum ResolverError: Error, CustomStringConvertible {
  case topLevelReturn
  case variableAlreadyDeclared(name: String)
  case variableUsedInOwnInitializer(name: String)
  case thisUsedOutsideOfClass
  case superUsedOutsideOfClass
  case superUsedWithoutSuperclass
  case returnInInitializer
  case selfInheritance

  var description: String {
    switch self {
    case .topLevelReturn:
      return "Cannot return from top-level code."
    case let .variableAlreadyDeclared(name):
      return "Variable '\(name)' was already declared in this scope."
    case let .variableUsedInOwnInitializer(name):
      return "Cannot read variable '\(name)' in its own initializer."
    case .thisUsedOutsideOfClass:
      return "Cannot use 'this' outside of a class."
    case .superUsedOutsideOfClass:
      return "Cannot use 'super' outside of a class."
    case .superUsedWithoutSuperclass:
      return "Cannot use 'super' in a class with no superclass."
    case .returnInInitializer:
      return "Cannot return a value from an initializer."
    case .selfInheritance:
      return "A class cannot inherit from itself."
    }
  }
}
