//
//  PostDetailView.swift
//  coffeU
//
//  Created by Xiaoqiang Wu on 9/8/24.
//

import SwiftUI
import MapKit

struct PostDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var post: Post
    @State private var editedContent: String
    @State private var region: MKCoordinateRegion
    var onSave: (Post) -> Void
    
    init(post: Binding<Post>, onSave: @escaping (Post) -> Void) {
        self._post = post
        self._editedContent = State(initialValue: post.wrappedValue.content)
        self._region = State(initialValue: MKCoordinateRegion(
            center: post.wrappedValue.location ?? CLLocationCoordinate2D(latitude: 0, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
        self.onSave = onSave
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                TextEditor(text: $editedContent)
                    .frame(height: 100)
                    .padding(4)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(8)
                
                if !post.imageNames.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(post.imageNames, id: \.self) { imageName in
                                if let image = loadImage(named: imageName) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 200)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                
                if post.location != nil {
                    Map(coordinateRegion: $region, annotationItems: [post]) { post in
                        MapMarker(coordinate: post.location!)
                    }
                    .frame(height: 200)
                    .cornerRadius(8)
                }
                
                Button("Save") {
                    post.content = editedContent
                    onSave(post)
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
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
