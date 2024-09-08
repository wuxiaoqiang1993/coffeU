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
    @State private var inputImages: [UIImage] = []
    
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
                
                ForEach(post.imageNames, id: \.self) { imageName in
                    if let image = loadImage(named: imageName) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(8)
                    }
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
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImages) {
            ImagePicker(images: $inputImages)
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func loadImages() {
        for image in inputImages {
            if let imageName = saveImage(image) {
                post.imageNames.append(imageName)
            }
        }
        inputImages = []
    }
    
    func loadImage(named filename: String) -> UIImage? {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    func saveImage(_ image: UIImage) -> String? {
        if let data = image.jpegData(compressionQuality: 0.8) {
            let filename = UUID().uuidString + ".jpg"
            let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
            try? data.write(to: fileURL)
            return filename
        }
        return nil
    }
}
