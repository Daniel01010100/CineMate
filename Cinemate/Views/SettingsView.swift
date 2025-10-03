//
//  SettingsView.swift
//  Cinemate
//
//  Created by YUDONG LU on 18/9/2025.
//

import SwiftUI
import PhotosUI

struct SettingsView: View {
    var cmvm: CineMateViewModel
    @State private var _showingSettings: Bool = false
    @State private var _isChangingAvatar: Bool = false
    @State private var _selectedPhoto: PhotosPickerItem? = nil
    @State private var _avatar: Data? = nil
    @State private var _username: String = "Unknown"
    @State private var _editingUsername: String = ""
    @State private var _language: Languages = .English
    @State private var _region: Regions = .Australia

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 20) {
                Button(action: {
                    self._isChangingAvatar.toggle()
                }) {
                    if let data = _avatar, let img = UIImage(data: data) {
                        Image(uiImage: img)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .foregroundColor(.gray)
                    }
                }
                .photosPicker(isPresented: $_isChangingAvatar, selection: $_selectedPhoto, matching: .images)
                
                Text(_username.isEmpty ? "New User" : _username)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            Divider()

            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Username Setting")
                        .font(.headline)
                        .bold()
                    
                    TextField("Your username", text: $_editingUsername)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .autocorrectionDisabled()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Preferred Language setting")
                        .font(.headline)
                        .bold()
                    Picker("Viewing Format", selection: $_language) {
                        ForEach(Languages.allCases, id: \.self) { language in
                            Text(language.label)
                                .tag(language)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(10)
                    .background(.gray.opacity(0.1))
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Country / Region Setting")
                        .font(.headline)
                        .bold()
                    Picker("Regions", selection: $_region) {
                        ForEach(Regions.allCases, id: \.self) { region in
                            Text("\(region.convertISOToNationalFlag()) \(region.label)")
                            .tag(region)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(10)
                    .background(.gray.opacity(0.1))
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button(action: {
                    cmvm.updateUsername(_editingUsername)
                    cmvm.updateUserCurrentRegion(_region)
                    cmvm.updateUserPreferredLanguage(_language)
                    self._editingUsername = ""
                    self._showingSettings.toggle()
                }) {
                    Text("Save")
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .tint(cmvm.cinemateColor)
                .padding(50)
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .onAppear() {
            cmvm.loadUserProfile()
            self._username = cmvm.user.username
            self._region = cmvm.user.currentRegion
            self._language = cmvm.user.preferredLanguage
            self._avatar = cmvm.user.avatar
        }
        .onChange(of: _selectedPhoto) { item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    self._avatar = data
                    cmvm.updateUserProfileAvatar(image)
                }
            }
        }
        .onChange(of: cmvm.user) { user in
            self._username = user.username
            self._region = user.currentRegion
            self._language = user.preferredLanguage
            self._avatar = user.avatar
        }
    }
}

struct BlueCapsuleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

#Preview {
    SettingsView(cmvm: CineMateViewModel())
}
