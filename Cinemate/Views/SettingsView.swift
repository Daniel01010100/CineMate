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
    @State private var _language: Languages = .English
    @State private var _region: Regions = .Australia

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self._isChangingAvatar.toggle()
                }, label: {
                    /*
                    if let data = cmvm.user.avatar, let img = UIImage(data: data) {
                        Image(uiImage: img)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .padding(.top, 80)
                    } else {
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .padding(.top, 80)
                    }
                     */
                })
                
                Text(_username)
                    .font(.largeTitle)
                    .bold()
            }
            
            Divider()
            
            Button(action: {
                self._showingSettings.toggle()
            }, label: {
                Image(systemName: "gearshape.circle")
                    .tint(cmvm.cinemateColor)
            })
            Spacer()
        }
        .onAppear() {
            cmvm.loadUserProfile()
            self._username = cmvm.user.username
            self._region = cmvm.user.currentRegion
            self._language = cmvm.user.preferredLanguage
            self._avatar = cmvm.user.avatar
        }
        .sheet(isPresented: $_showingSettings) {
            Form {
                Section(header: Text("Account")) {
                    TextField("Your username", text: $_username)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .autocorrectionDisabled()
                        .textContentType(.username)
                }

                Section(header: Text("Language Preference")) {
                    Picker("Language", selection: $_language) {
                        ForEach(Languages.allCases, id: \.self) { lang in
                            Text(lang.label)
                                .tag(lang)
                        }
                    }
                }

                Section(header: Text("Region")) {
                    Picker("Country / Region", selection: $_region) {
                        ForEach(Regions.allCases, id: \.self) { region in
                            HStack {
                                Text("\(region.convertISOToNationalFlag()) \(region.rawValue)")
                            }
                            .tag(region)
                        }
                    }
                }
                
                Button(action: {
                    cmvm.updateUserCurrentRegion(_region)
                    cmvm.updateUserPreferredLanguage(_language)
                    self._showingSettings.toggle()
                }, label: {
                    Text("Save")
                })
            }
        }
    }
}

#Preview {
    SettingsView(cmvm: CineMateViewModel())
}
