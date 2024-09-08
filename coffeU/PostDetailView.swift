//
//  PostDetailView.swift
//  coffeU
//
//  Created by Xiaoqiang Wu on 9/8/24.
//

import SwiftUI

struct PostDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var post: Post
    @State private var editedContent: String
    var onSave: (Post) -> Void
    
    init(post: Binding<Post>, onSave: @escaping (Post) -> Void) {
        self._post = post
        self._editedContent = State(initialValue: post.wrappedValue.content)
        self.onSave = onSave
    }
    
    var body: some View {
        VStack {
            TextEditor(text: $editedContent)
                .padding()
            
            // Display images if any
            if !post.imageNames.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(post.imageNames, id: \.self) { imageName in
                            if let image = loadImage(named: imageName) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                            }
                        }
                    }
                }
            }
            
            Button("Save") {
                post.content = editedContent
                onSave(post)
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
        .navigationTitle("Edit Post")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func loadImage(named filename: String) -> UIImage? {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
        return UIImage(contentsOfFile: fileURL.path)
    }
}
