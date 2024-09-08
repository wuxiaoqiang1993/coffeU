//
//  MainView.swift
//  coffeU
//
//  Created by Xiaoqiang Wu on 9/5/24.
//

import SwiftUI
import UIKit
import Foundation

struct MainView: View {
    @State private var posts: [Post] = []
    @State private var newPostContent = ""
    @State private var showingImagePicker = false
    @State private var inputImages: [UIImage] = []
    @State private var showingProfile = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(posts) { post in
                        VStack(alignment: .leading) {
                            NavigationLink(destination: PostDetailView(post: binding(for: post))) {
                                VStack(alignment: .leading) {
                                    Text(post.content)
                                    Text(formatDate(post.date))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    if !post.imageNames.isEmpty {
                                        ImagePreviewRow(imageNames: post.imageNames)
                                    }
                                }
                            }
                            HStack {
                                Spacer()
                                Button(action: {
                                    sharePost(post)
                                }) {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share")
                                }
                                .foregroundColor(.blue)
                            }
                        }
                    }
                    .onDelete(perform: deletePosts)
                }
                
                HStack {
                    TextField("New post", text: $newPostContent)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Add Images") {
                        showingImagePicker = true
                    }
                    Button("Post") {
                        if !newPostContent.isEmpty {
                            let imageNames = inputImages.compactMap { saveImage($0) }
                            let newPost = Post(content: newPostContent, date: Date(), imageNames: imageNames)
                            posts.insert(newPost, at: 0)
                            savePosts()
                            newPostContent = ""
                            inputImages = []
                            print("Post created")
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Coffee Posts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ProfileIcon(action: { showingProfile = true })
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
        }
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImages) {
            ImagePicker(images: $inputImages)
        }
        .sheet(isPresented: $showingProfile) {
            NavigationView {
                ProfileView(
                    joinDate: Date().addingTimeInterval(-30 * 24 * 60 * 60),
                    membershipStatus: "Premium Member",
                    postCount: posts.count
                )
            }
        }
        .onAppear(perform: loadPosts)
    }

    // Add this function to create a binding for a post
    private func binding(for post: Post) -> Binding<Post> {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else {
            fatalError("Post not found")
        }
        return $posts[index]
    }

    // ... (keep all other existing functions)

    func deletePosts(at offsets: IndexSet) {
        posts.remove(atOffsets: offsets)
        savePosts()
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func loadImages() {
        // You can add additional processing here if needed
    }
    
    func sharePost(_ post: Post) {
        let textToShare = post.content
        var itemsToShare: [Any] = [textToShare]
        
        if let firstImageName = post.imageNames.first, let image = loadImage(named: firstImageName) {
            itemsToShare.append(image)
        }
        
        let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            rootViewController.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    func savePosts() {
        do {
            let data = try JSONEncoder().encode(posts)
            try data.write(to: getDocumentsDirectory().appendingPathComponent("posts.json"))
        } catch {
            print("Failed to save posts: \(error.localizedDescription)")
        }
    }

    func loadPosts() {
        let fileURL = getDocumentsDirectory().appendingPathComponent("posts.json")
        if let data = try? Data(contentsOf: fileURL) {
            do {
                posts = try JSONDecoder().decode([Post].self, from: data)
            } catch {
                print("Failed to load posts: \(error.localizedDescription)")
            }
        }
    }

    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func saveImage(_ image: UIImage) -> String? {
        if let data = image.jpegData(compressionQuality: 0.8) {
            let filename = UUID().uuidString + ".jpg"
            let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
            try? data.write(to: fileURL)
            return filename
        }
        return nil
    }

    func loadImage(named filename: String) -> UIImage? {
        let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
        return UIImage(contentsOfFile: fileURL.path)
    }
}

struct ImagePreviewRow: View {
    let imageNames: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(imageNames.prefix(3), id: \.self) { imageName in
                    if let image = loadImage(named: imageName) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                if imageNames.count > 3 {
                    Text("+\(imageNames.count - 3)")
                        .frame(width: 80, height: 80)
                        .background(Color.gray.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }
    
    func loadImage(named filename: String) -> UIImage? {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
        return UIImage(contentsOfFile: fileURL.path)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
