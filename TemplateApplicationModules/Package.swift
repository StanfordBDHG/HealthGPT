// swift-tools-version: 5.7

//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import PackageDescription


let package = Package(
    name: "TemplateModules",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "TemplateContacts", targets: ["TemplateContacts"]),
        .library(name: "TemplateMockDataStorageProvider", targets: ["TemplateMockDataStorageProvider"]),
        .library(name: "TemplateOnboardingFlow", targets: ["TemplateOnboardingFlow"]),
        .library(name: "TemplateSchedule", targets: ["TemplateSchedule"]),
        .library(name: "TemplateSharedContext", targets: ["TemplateSharedContext"])
    ],
    dependencies: [
        .package(url: "https://github.com/StanfordBDHG/CardinalKit.git", .upToNextMinor(from: "0.2.1"))
    ],
    targets: [
        .target(
            name: "TemplateContacts",
            dependencies: [
                .target(name: "TemplateSharedContext"),
                .product(name: "Contact", package: "CardinalKit")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "TemplateMockDataStorageProvider",
            dependencies: [
                .target(name: "TemplateSharedContext"),
                .product(name: "CardinalKit", package: "CardinalKit"),
                .product(name: "FHIR", package: "CardinalKit")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "TemplateOnboardingFlow",
            dependencies: [
                .target(name: "TemplateSharedContext"),
                .product(name: "FHIR", package: "CardinalKit"),
                .product(name: "HealthKitDataSource", package: "CardinalKit"),
                .product(name: "Onboarding", package: "CardinalKit")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "TemplateSchedule",
            dependencies: [
                .target(name: "TemplateSharedContext"),
                .product(name: "FHIR", package: "CardinalKit"),
                .product(name: "Questionnaires", package: "CardinalKit"),
                .product(name: "Scheduler", package: "CardinalKit")
            ]
        ),
        .target(
            name: "TemplateSharedContext",
            dependencies: []
        )
    ]
)
