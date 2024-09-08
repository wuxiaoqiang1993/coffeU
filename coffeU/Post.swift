//
//  Post.swift
//  coffeU
//
//  Created by Xiaoqiang Wu on 9/8/24.
//

import Foundation
import UIKit

struct Post: Identifiable, Codable {
    let id: UUID
    var content: String
    let date: Date
    var imageNames: [String]

    init(id: UUID = UUID(), content: String, date: Date, imageNames: [String]) {
        self.id = id
        self.content = content
        self.date = date
        self.imageNames = imageNames
    }
}
