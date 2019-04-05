// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "Lox",
  targets: [
    .target(
      name: "Lox",
      dependencies: []
    ),
    .target(
      name: "Code generator",
      dependencies: []
    ),
    .testTarget(
      name: "LoxTests",
      dependencies: ["Lox"],
      path: "Tests"
    )
  ]
)
