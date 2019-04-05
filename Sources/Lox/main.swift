// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

debug = false

let args = CommandLine.arguments.dropFirst()
try Lox.main(["/Users/michal/Documents/Xcode/Lox/main.lox"])
//try Lox.main(Array(args))
