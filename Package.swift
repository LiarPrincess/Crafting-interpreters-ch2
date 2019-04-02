// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "Lox",
  targets: [
    .target(
      name: "Lox",
      dependencies: [],
      path: "Sources"
    ),
    .testTarget(
      name: "LoxTests",
      dependencies: ["Lox"],
      path: "Tests"
    )
  ]
)
