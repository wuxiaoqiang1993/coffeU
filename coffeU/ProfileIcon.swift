//
//  ProfileIcon.swift
//  coffeU
//
//  Created by Xiaoqiang Wu on 9/8/24.
//

import SwiftUI

struct ProfileIcon: View {
    var action: () -> Void
    var size: CGFloat = 22 // Adjust this value to change the icon size
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "cup.and.saucer.fill") // Use a coffee cup icon
                .font(.system(size: size))
                .foregroundColor(.blue) // Adjust color as needed
        }
    }
}
