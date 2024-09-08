import SwiftUI
import UIKit
import Foundation
import CoreLocation

struct MainView: View {
    @State private var posts: [Post] = []
    @State private var newPostContent = ""
    @State private var showingImagePicker = false
    @State private var inputImages: [UIImage] = []
    @State private var showingProfile = false
    @ObservedObject var profileViewModel: ProfileViewModel
    @State private var searchText = ""
    @StateObject private var locationManager = LocationManager()
    
    var filteredPosts: [Post] {
        if searchText.isEmpty {
            return posts
        } else {
            return posts.filter { $0.content.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search posts", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                List {
                    ForEach(filteredPosts) { post in
                        VStack(alignment: .leading) {
                            NavigationLink(destination: PostDetailView(post: binding(for: post), onSave: { updatedPost in
                                if let index = posts.firstIndex(where: { $0.id == updatedPost.id }) {
                                    posts[index] = updatedPost
                                    savePosts()
                                }
                            })) {
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
                            .buttonStyle(PlainButtonStyle()) // This ensures the NavigationLink doesn't affect the share button
                            
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
                        createPost()
                    }
                }
                .padding()
            }
            .navigationTitle("My Coffee Posts")
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
                ProfileView(viewModel: profileViewModel)
            }
        }
        .onAppear(perform: loadPosts)
    }

    // Keep all other existing functions as they are


    private func binding(for post: Post) -> Binding<Post> {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else {
            fatalError("Post not found")
        }
        return $posts[index]
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func sharePost(_ post: Post) {
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

    private func deletePosts(at offsets: IndexSet) {
        posts.remove(atOffsets: offsets)
        savePosts()
        profileViewModel.updatePostCount(posts.count)
    }

    private func createPost() {
        if !newPostContent.isEmpty {
            let imageNames = inputImages.compactMap { saveImage($0) }
            let newPost = Post(content: newPostContent, date: Date(), imageNames: imageNames, location: locationManager.lastKnownLocation)
            posts.insert(newPost, at: 0)
            savePosts()
            newPostContent = ""
            inputImages = []
            profileViewModel.updatePostCount(posts.count)
        }
    }

    private func loadImages() {
        // This function is called after the image picker is dismissed
        // You can add any additional processing for the selected images here if needed
    }

    private func loadPosts() {
        if let savedPosts = UserDefaults.standard.data(forKey: "posts") {
            if let decodedPosts = try? JSONDecoder().decode([Post].self, from: savedPosts) {
                posts = decodedPosts
                profileViewModel.updatePostCount(posts.count)
            }
        }
    }

    private func savePosts() {
        if let encodedPosts = try? JSONEncoder().encode(posts) {
            UserDefaults.standard.set(encodedPosts, forKey: "posts")
        }
        profileViewModel.updatePostCount(posts.count)
    }

    private func saveImage(_ image: UIImage) -> String? {
        if let data = image.jpegData(compressionQuality: 0.8) {
            let filename = UUID().uuidString + ".jpg"
            let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
            try? data.write(to: fileURL)
            return filename
        }
        return nil
    }

    private func loadImage(named filename: String) -> UIImage? {
        let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
        return UIImage(contentsOfFile: fileURL.path)
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var lastKnownLocation: CLLocationCoordinate2D?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastKnownLocation = locations.first?.coordinate
    }
}
