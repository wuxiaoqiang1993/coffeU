//
//  ProfileViewModel.swift
//  coffeU
//
//  Created by Xiaoqiang Wu on 9/8/24.
//

// ProfileViewModel.swift

import Foundation

class ProfileViewModel: ObservableObject {
    @Published var postCount: Int = 0
    @Published var joinDate: Date
    @Published var membershipStatus: String
    
    init(joinDate: Date = Date().addingTimeInterval(-30 * 24 * 60 * 60), membershipStatus: String = "Premium Member") {
        self.joinDate = joinDate
        self.membershipStatus = membershipStatus
    }
    
    func updatePostCount(_ count: Int) {
        postCount = count
    }
}
