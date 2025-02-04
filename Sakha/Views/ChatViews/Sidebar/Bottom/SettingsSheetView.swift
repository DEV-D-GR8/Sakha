//
//  SettingsSheetView.swift
//  Sakha
//
//  Created by Dev Asheesh Chopra on 04/02/25.
//

import SwiftUI
// ADDED: A dedicated Settings sheet
struct SettingsSheetView: View {
    @EnvironmentObject var chatManager: ChatManager

    // For picking image
    @State private var showImagePicker = false
    @State private var tempImage: UIImage? = nil

    var body: some View {
        NavigationView {
            VStack {
                // Attractive top area with gradient
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 120)
                .overlay(
                    VStack {
                        // Profile image or placeholder
                        ZStack {
                            if let data = chatManager.profileImageData,
                               let uiImg = UIImage(data: data) {
                                Image(uiImage: uiImg)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                            } else {
                                Image(systemName: "person.crop.circle.fill.badge.plus")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.white)
                            }
                        }
                        .onTapGesture {
                            showImagePicker = true
                        }
                        Text("Tap to change photo")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 20)
                )

                Form {
                    Section(header: Text("User Profile")) {
                        TextField("Your Name", text: $chatManager.userName)
                            .textInputAutocapitalization(.words)
                    }

                    Section(header: Text("Language")) {
                        Picker("Response Language", selection: $chatManager.responseLanguage) {
                            Text("English").tag("English")
                            Text("Hindi").tag("Hindi")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }

                    Section {
                        Button(role: .destructive) {
                            // Reset to defaults on "Log Out"
                            chatManager.userName = "John Doe"
                            chatManager.profileImageData = nil
                            chatManager.responseLanguage = "English"
                        } label: {
                            Text("Log Out")
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                        }
                    }
                }
                .formStyle(.grouped)
            }
            .navigationBarTitle("Settings", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        // Just dismiss
                        UIApplication.shared.endEditing()
                    }
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $tempImage)
                .onDisappear {
                    // When user finishes picking:
                    if let uiImg = tempImage {
                        chatManager.profileImageData = uiImg.pngData()
                    }
                }
        }
    }
}
