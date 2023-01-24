//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import CardinalKit
import FHIR
import Foundation


/// A data storage provider that collects all uploads and displays them in a user interface using the ``MockUploadList``.
public actor MockDataStorageProvider: DataStorageProvider, ObservableObjectProvider, ObservableObject {
    public typealias ComponentStandard = FHIR
    
    
    let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        return encoder
    }()
    @MainActor @Published
    private(set) var mockUploads: [MockUpload] = []
    
    
    public init() { }
    
    
    public func process(_ element: DataChange<ComponentStandard.BaseType, ComponentStandard.RemovalContext>) async throws {
        switch element {
        case let .addition(element):
            let data = try encoder.encode(element)
            let json = String(decoding: data, as: UTF8.self)
            _Concurrency.Task { @MainActor in
                mockUploads.insert(
                    MockUpload(
                        id: element.id.description,
                        type: .add,
                        path: ResourceProxy(with: element).resourceType.description,
                        body: json
                    ),
                    at: 0
                )
            }
        case let .removal(removalContext):
            _Concurrency.Task { @MainActor in
                mockUploads.insert(
                    MockUpload(
                        id: removalContext.id.description,
                        type: .delete,
                        path: removalContext.resourceType.rawValue
                    ),
                    at: 0
                )
            }
        }
    }
}
