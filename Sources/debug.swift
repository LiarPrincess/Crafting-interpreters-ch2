// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

var debug = true

private func getFileName(_ file: StaticString) -> String {
  var fileString = String(describing: file)

  if let index = fileString.lastIndex(of: "/") {
    fileString = String(fileString.suffix(from: index)).replacingOccurrences(of: "/", with: "")
  }

  return fileString
}

func printDebug(message:  String = "",
                file:     StaticString = #file,
                function: StaticString = #function,
                line:     UInt = #line) {

  guard debug else { return }
  let fileName = getFileName(file)
  print("[\(fileName):\(line)] \(function) -> \(message)")
}
