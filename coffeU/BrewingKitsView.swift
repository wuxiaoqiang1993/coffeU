//
//  BrewingKitsView.swift
//  coffeU
//
//  Created by Xiaoqiang Wu on 9/8/24.
//

import SwiftUI

struct BrewingKit: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var imageName: String?
    var category: String
    
    init(id: UUID = UUID(), name: String, description: String, imageName: String? = nil, category: String) {
        self.id = id
        self.name = name
        self.description = description
        self.imageName = imageName
        self.category = category
    }
}

struct BrewingKitsView: View {
    @State private var brewingKits: [BrewingKit] = []
    @State private var showingAddKit = false
    @State private var newKitName = ""
    @State private var newKitDescription = ""
    @State private var newKitImage: UIImage?
    @State private var newKitCategory = ""
    @State private var customCategory = ""
    @State private var showingImagePicker = false
    
    let predefinedCategories = ["Coffee Machine", "Coffee Cup", "Distribution Tool", "Coffee Beans"]
    
    var groupedKits: [String: [BrewingKit]] {
        Dictionary(grouping: brewingKits, by: { $0.category })
    }
    
    var body: some View {
        List {
            ForEach(groupedKits.keys.sorted(), id: \.self) { category in
                Section(header: Text(category)) {
                    ForEach(groupedKits[category]!) { kit in
                        NavigationLink(destination: BrewingKitDetailView(kit: binding(for: kit), saveAction: saveKits, predefinedCategories: predefinedCategories)) {
                            HStack {
                                if let imageName = kit.imageName, let uiImage = loadImage(named: imageName) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                } else {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.gray)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(kit.name)
                                        .font(.headline)
                                    Text(kit.description)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .onDelete { indexSet in
                        deleteKits(at: indexSet, in: category)
                    }
                }
            }
        }
        .navigationTitle("My Brewing Kits")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddKit = true }) {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
        }
        .sheet(isPresented: $showingAddKit) {
            NavigationView {
                Form {
                    TextField("Kit Name", text: $newKitName)
                    TextField("Description", text: $newKitDescription)
                    
                    Picker("Category", selection: $newKitCategory) {
                        ForEach(predefinedCategories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                        Text("Custom").tag("Custom")
                    }
                    
                    if newKitCategory == "Custom" {
                        TextField("Enter custom category", text: $customCategory)
                    }
                    
                    Button("Add Image") {
                        showingImagePicker = true
                    }
                    if let image = newKitImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                    }
                }
                .navigationTitle("Add Brewing Kit")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            saveNewKit()
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showingAddKit = false
                        }
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                BrewingKitImagePicker(image: $newKitImage)
            }
        }
        .onAppear(perform: loadKits)
    }
    
    private func saveNewKit() {
        var imageName: String?
        if let image = newKitImage {
            imageName = saveImage(image)
        }
        let category = newKitCategory == "Custom" ? customCategory : newKitCategory
        let newKit = BrewingKit(name: newKitName, description: newKitDescription, imageName: imageName, category: category)
        brewingKits.append(newKit)
        saveKits()
        
        // Reset form and dismiss sheet
        showingAddKit = false
        newKitName = ""
        newKitDescription = ""
        newKitImage = nil
        newKitCategory = ""
        customCategory = ""
    }
    
    private func binding(for kit: BrewingKit) -> Binding<BrewingKit> {
        guard let index = brewingKits.firstIndex(where: { $0.id == kit.id }) else {
            fatalError("Can't find kit in array")
        }
        return $brewingKits[index]
    }
    
    private func deleteKits(at offsets: IndexSet, in category: String) {
        guard let kitsInCategory = groupedKits[category] else { return }
        var indexSetInMain = IndexSet()
        for offset in offsets {
            if let index = brewingKits.firstIndex(where: { $0.id == kitsInCategory[offset].id }) {
                indexSetInMain.insert(index)
            }
        }
        brewingKits.remove(atOffsets: indexSetInMain)
        saveKits()
    }
    
    private func saveKits() {
        if let encoded = try? JSONEncoder().encode(brewingKits) {
            UserDefaults.standard.set(encoded, forKey: "BrewingKits")
        }
    }
    
    private func loadKits() {
        if let savedKits = UserDefaults.standard.data(forKey: "BrewingKits") {
            if let decodedKits = try? JSONDecoder().decode([BrewingKit].self, from: savedKits) {
                brewingKits = decodedKits
            }
        }
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

struct BrewingKitDetailView: View {
    @Binding var kit: BrewingKit
    @State private var showingImagePicker = false
    @State private var newImage: UIImage?
    @State private var hasChanges = false
    @State private var showingSaveConfirmation = false
    @State private var customCategory = ""
    var saveAction: () -> Void
    @Environment(\.presentationMode) var presentationMode
    let predefinedCategories: [String]
    
    var body: some View {
        Form {
            TextField("Kit Name", text: Binding(
                get: { self.kit.name },
                set: { self.kit.name = $0; self.hasChanges = true }
            ))
            TextField("Description", text: Binding(
                get: { self.kit.description },
                set: { self.kit.description = $0; self.hasChanges = true }
            ))
            
            Picker("Category", selection: Binding(
                get: { predefinedCategories.contains(self.kit.category) ? self.kit.category : "Custom" },
                set: {
                    if $0 != "Custom" {
                        self.kit.category = $0
                    } else {
                        self.customCategory = self.kit.category
                    }
                    self.hasChanges = true
                }
            )) {
                ForEach(predefinedCategories, id: \.self) { category in
                    Text(category).tag(category)
                }
                Text("Custom").tag("Custom")
            }
            
            if !predefinedCategories.contains(kit.category) {
                TextField("Custom Category", text: Binding(
                    get: { self.customCategory },
                    set: {
                        self.customCategory = $0
                        self.kit.category = $0
                        self.hasChanges = true
                    }
                ))
            }
            
            Button("Change Image") {
                showingImagePicker = true
            }
            
            if let imageName = kit.imageName, let uiImage = loadImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
            } else if let newImage = newImage {
                Image(uiImage: newImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
            }
        }
        .navigationTitle("Edit Brewing Kit")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if hasChanges {
                    Button("Save") {
                        if let image = newImage {
                            kit.imageName = saveImage(image)
                        }
                        saveAction()
                        hasChanges = false
                        showingSaveConfirmation = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            BrewingKitImagePicker(image: $newImage)
        }
        .onChange(of: newImage) { _ in
            hasChanges = true
        }
        .alert(isPresented: $showingSaveConfirmation) {
            Alert(
                title: Text("Changes Saved"),
                message: Text("Your changes have been saved successfully."),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .onAppear {
            if !predefinedCategories.contains(kit.category) {
                customCategory = kit.category
            }
        }
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

    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

struct BrewingKitImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: BrewingKitImagePicker
        
        init(_ parent: BrewingKitImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct BrewingKitsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BrewingKitsView()
        }
    }
}
