//
//  ProfileView.swift
//  coffeU
//
//  Created by Xiaoqiang Wu on 9/8/24.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    
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
                        Text(viewModel.membershipStatus)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
                
                HStack {
                    Text("Joined")
                    Spacer()
                    Text(formatDate(viewModel.joinDate))
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Posts")
                    Spacer()
                    Text("\(viewModel.postCount)")
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
