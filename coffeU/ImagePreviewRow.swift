//
//  ImagePreviewRow.swift
//  coffeU
//
//  Created by Xiaoqiang Wu on 9/8/24.
//

import SwiftUI

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
