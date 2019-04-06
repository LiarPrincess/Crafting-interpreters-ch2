// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.

struct Field {
  let name: String
  let type: String
}

struct Template {
  let name:   String
  let fields: [Field]
}

private func getVisitorName(_ baseClassName: String) -> String {
  return "\(baseClassName)Visitor"
}

private func getTypeName(_ baseClassName: String, _ template: Template) -> String {
  return "\(template.name)\(baseClassName)"
}

private func getVisitorResultName(_ baseClassName: String) -> String {
  return "\(baseClassName)Result"
}

func printVisitorProtocol(_ baseClassName: String, _ templates: [Template]) {
  let visitorName = getVisitorName(baseClassName)
  let visitorResult = getVisitorResultName(baseClassName)
  let baseClassNameLowercase = baseClassName.lowercased()

  print("protocol \(visitorName) {")
  print("  associatedtype \(visitorResult)")
  print("")

  for template in templates {
    let type = getTypeName(baseClassName, template)
    print("  @discardableResult")
    print("  func visit\(type)(_ \(baseClassNameLowercase): \(type)) throws -> \(visitorResult)")
  }
  print("}")
  print("")

  print("extension \(visitorName) {")
  print("  func visit(_ \(baseClassNameLowercase): \(baseClassName)) throws -> \(visitorResult) {")
  print("    switch \(baseClassNameLowercase) {")
  for template in templates {
    let type = getTypeName(baseClassName, template)
    print("    case let \(baseClassNameLowercase) as \(type):")
    print("      return try self.visit\(type)(\(baseClassNameLowercase))")
  }
  print("    default:")
  print("      fatalError(\"Unknown \(baseClassNameLowercase) \\(\(baseClassNameLowercase))\")")
  print("    }")
  print("  }")
  print("}")
  print("")
}

func printBaseClass(_ baseClassName: String) {
  let visitorName = getVisitorName(baseClassName)
  let visitorResult = getVisitorResultName(baseClassName)

  print("class \(baseClassName): Equatable, Hashable {")
  print("")

  print("  func accept<V: \(visitorName), R>(_ visitor: V) throws -> R where R == V.\(visitorResult) {")
  print("    fatalError(\"Accept metod should be overriden in subclass\")")
  print("  }")
  print("")

  print("  static func == (lhs: \(baseClassName), rhs: \(baseClassName)) -> Bool {")
  print("    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)")
  print("  }")

  print("  func hash(into hasher: inout Hasher) {")
  print("    hasher.combine(ObjectIdentifier(self).hashValue)")
  print("  }")

  print("}")
  print("")
}

func printTypes(_ baseClassName: String, _ templates: [Template]) {
  let visitorName = getVisitorName(baseClassName)
  let visitorResult = getVisitorResultName(baseClassName)

  for template in templates {
    let type = getTypeName(baseClassName, template)
    print("class \(type): \(baseClassName) {")

    for field in template.fields {
      print("  let \(field.name): \(field.type)")
    }
    print("")

    if !template.fields.isEmpty {
      let ctorParameters = template.fields.map { "\($0.name): \($0.type)" }.joined(separator: ", ")
      print("  init(\(ctorParameters)) {")
      for field in template.fields {
        print("    self.\(field.name) = \(field.name)")
      }
      print("  }")
      print("")
    }

    print("  override func accept<V: \(visitorName), R>(_ visitor: V) throws -> R where R == V.\(visitorResult) {")
    print("    return try visitor.visit\(type)(self)")
    print("  }")

    print("}")
    print("")
  }
}
