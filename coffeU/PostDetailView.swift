//
//  PostDetailView.swift
//  coffeU
//
//  Created by Xiaoqiang Wu on 9/8/24.
//

import SwiftUI

struct PostDetailView: View {
    @Binding var post: Post
    @State private var isEditing = false
    @State private var editedContent: String = ""
    @State private var showingImagePicker = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                TextEditor(text: $post.content)
                    .frame(minHeight: 100)
                    .padding(4)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(8)
                
                Text(formatDate(post.date))
                    .font(.caption)
                    .foregroundColor(.gray)
                
                ForEach(post.images.indices, id: \.self) { index in
                    Image(uiImage: post.images[index])
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(8)
                        .overlay(
                            Button(action: {
                                post.images.remove(at: index)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white)
                                    .background(Color.black.opacity(0.7))
                                    .clipShape(Circle())
                            }
                            .padding(8),
                            alignment: .topTrailing
                        )
                }
                
                Button(action: {
                    showingImagePicker = true
                }) {
                    Label("Add Image", systemImage: "photo")
                }
                .padding(.vertical)
            }
            .padding()
        }
        .navigationTitle("Edit Post")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    // Save changes if needed
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(images: $post.images)
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
