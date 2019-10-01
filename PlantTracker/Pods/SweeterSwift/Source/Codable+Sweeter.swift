//
//  Codable+Sweeter.swift
//
//  Created by Yonat Sharon on 2019-02-08.
//

extension Decodable {
    /// SweeterSwift: Create object from a dictionary
    public init?(from: Any) {
        guard let data = try? JSONSerialization.data(withJSONObject: from, options: .prettyPrinted) else { return nil }
        guard let decodedSelf = try? JSONDecoder().decode(Self.self, from: data) else { return nil }
        self = decodedSelf
    }
}

extension Encodable {
    /// SweeterSwift: Export object to a dictionary representation
    public var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
