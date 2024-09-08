//
//  HomePage.swift
//  coffeU
//
//  Created by Xiaoqiang Wu on 9/8/24.
//

import SwiftUI

struct HomePage: View {
    @State private var showingProfile = false
    @StateObject private var profileViewModel = ProfileViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Image
                Image("coffee-background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(Color.black.opacity(0.3))
                
                VStack(spacing: 30) {
                    Text("Coffee U")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 50)
                    
                    Spacer()
                    
                    NavigationLink(destination: RecommendedPostsView()) {
                        HomePageButton(title: "Recommended Posts", systemImage: "star.fill")
                    }
                    
                    NavigationLink(destination: MainView(profileViewModel: profileViewModel)) {
                        HomePageButton(title: "My Coffee Posts", systemImage: "cup.and.saucer.fill")
                    }
                    
                    NavigationLink(destination: ShopView()) {
                        HomePageButton(title: "Shop", systemImage: "cart.fill")
                    }
                    
                    NavigationLink(destination: BrewingKitsView()) {
                        HomePageButton(title: "My Brewing Kits", systemImage: "list.bullet")
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ProfileIcon(action: { showingProfile = true })
                }
            }
        }
        .sheet(isPresented: $showingProfile) {
            NavigationView {
                ProfileView(viewModel: profileViewModel)
            }
        }
    }
}

struct HomePageButton: View {
    let title: String
    let systemImage: String
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .font(.title2)
                .frame(width: 30)
            Text(title)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.15))
        .foregroundColor(.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}
