//
//  SettingsView.swift
//  Cinemate
//
//  Created by YUDONG LU on 18/9/2025.
//

import SwiftUI

struct SettingsView: View {
    var cmvm: CineMateViewModel

    @State private var _username: String = ""
    @State private var _language: Languages = .English
    @State private var _region: Regions = .Australia

    var body: some View {
        NavigationStack {
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
                            Text(lang.rawValue)
                        }
                    }
                }

                Section(header: Text("Region")) {
                    Picker("Region", selection: $_region) {
                        ForEach(Regions.allCases, id: \.self) { region in
                            Text(region.rawValue)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView(cmvm: CineMateViewModel())
}
