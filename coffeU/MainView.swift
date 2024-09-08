//
//  MainView.swift
//  coffeU
//
//  Created by Xiaoqiang Wu on 9/5/24.
//

// MainView.swift
import SwiftUI
import UIKit
struct Post: Identifiable {
    let id = UUID()
    var content: String
    let date: Date
    var images: [UIImage]
}




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
                                    if !post.images.isEmpty {
                                        ImagePreviewRow(images: post.images)
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
                            posts.insert(Post(content: newPostContent, date: Date(), images: inputImages), at: 0)
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
                    Button(action: {
                        showingProfile = true
                    }) {
                        Image(systemName: "person.crop.circle")
                    }
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
    }

    func deletePosts(at offsets: IndexSet) {
        posts.remove(atOffsets: offsets)
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
    
    private func binding(for post: Post) -> Binding<Post> {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else {
            fatalError("Post not found")
        }
        return $posts[index]
    }
    
    func sharePost(_ post: Post) {
        let textToShare = post.content
        var itemsToShare: [Any] = [textToShare]
        
        if let firstImage = post.images.first {
            itemsToShare.append(firstImage)
        }
        
        let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            rootViewController.present(activityViewController, animated: true, completion: nil)
        }
    }
}

struct ImagePreviewRow: View {
    let images: [UIImage]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(images.prefix(3), id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                if images.count > 3 {
                    Text("+\(images.count - 3)")
                        .frame(width: 80, height: 80)
                        .background(Color.gray.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }
}
// ... (keep the ImagePreviewRow struct)
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
