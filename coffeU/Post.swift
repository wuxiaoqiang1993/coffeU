//
//  Post.swift
//  coffeU
//
//  Created by Xiaoqiang Wu on 9/8/24.
//

import Foundation
import CoreLocation
import UIKit

struct Post: Identifiable, Codable {
    let id: UUID
    var content: String
    let date: Date
    var imageNames: [String]
    var location: CLLocationCoordinate2D?

    enum CodingKeys: String, CodingKey {
        case id, content, date, imageNames, latitude, longitude
    }

    init(id: UUID = UUID(), content: String, date: Date, imageNames: [String], location: CLLocationCoordinate2D? = nil) {
        self.id = id
        self.content = content
        self.date = date
        self.imageNames = imageNames
        self.location = location
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        content = try container.decode(String.self, forKey: .content)
        date = try container.decode(Date.self, forKey: .date)
        imageNames = try container.decode([String].self, forKey: .imageNames)
        
        if let latitude = try container.decodeIfPresent(Double.self, forKey: .latitude),
           let longitude = try container.decodeIfPresent(Double.self, forKey: .longitude) {
            location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            location = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(content, forKey: .content)
        try container.encode(date, forKey: .date)
        try container.encode(imageNames, forKey: .imageNames)
        
        if let location = location {
            try container.encode(location.latitude, forKey: .latitude)
            try container.encode(location.longitude, forKey: .longitude)
        }
    }
}
