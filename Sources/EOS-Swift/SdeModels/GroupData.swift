//
//  GroupData.swift
//  EOS-Swift
//
//  Created by Erik Hatfield on 9/24/25.
//

public struct GroupData: Codable, Sendable {
    public let anchorable: Bool
    public let anchored: Bool
    public let categoryID: Int64
    public let fittableNonSingleton: Bool
    public let name: ThingName
    public let published: Bool
    public let useBasePrice: Bool
    
    public init(id: Int64, name: String) {
        self.init(
            anchorable: true,
            anchored: true,
            categoryID: id,
            fittableNonSingleton: true,
            name: ThingName(name: name),
            published: true,
            useBasePrice: true)
    }
    
    public init(anchorable: Bool,
        anchored: Bool,
        categoryID: Int64,
        fittableNonSingleton: Bool,
        name: ThingName,
        published: Bool,
        useBasePrice: Bool
    ) {
        self.anchorable = anchorable
        self.anchored = anchored
        self.categoryID = categoryID
        self.fittableNonSingleton = fittableNonSingleton
        self.name = name
        self.published = published
        self.useBasePrice = useBasePrice
    }
}
