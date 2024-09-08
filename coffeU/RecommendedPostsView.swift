//
//  RecommendedPostsView.swift
//  coffeU
//
//  Created by Xiaoqiang Wu on 9/8/24.
//

import SwiftUI

struct RecommendedPostsView: View {
    let recommendedPosts = [
        Post(content: "Try our new Vanilla Latte!", date: Date(), imageNames: []),
        Post(content: "Coffee of the month: Ethiopian Yirgacheffe", date: Date(), imageNames: []),
        Post(content: "How to brew the perfect pour-over", date: Date(), imageNames: [])
    ]
    
    var body: some View {
        List(recommendedPosts) { post in
            VStack(alignment: .leading) {
                Text(post.content)
                Text(formatDate(post.date))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle("Recommended Posts")
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
