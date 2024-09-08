//
//  ProfileView.swift
//  coffeU
//
//  Created by Xiaoqiang Wu on 9/8/24.
//

import SwiftUI

struct ProfileView: View {
    let joinDate: Date
    let membershipStatus: String
    let postCount: Int
    
    var body: some View {
        List {
            Section(header: Text("User Information")) {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.blue)
                    VStack(alignment: .leading) {
                        Text("User Name")
                            .font(.headline)
                        Text(membershipStatus)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
                
                HStack {
                    Text("Joined")
                    Spacer()
                    Text(formatDate(joinDate))
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Posts")
                    Spacer()
                    Text("\(postCount)")
                        .foregroundColor(.secondary)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Profile")
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
