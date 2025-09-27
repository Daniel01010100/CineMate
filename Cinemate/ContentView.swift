//
//  ContentView.swift
//  Cinemate
//
//  Created by YUDONG LU on 14/9/2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Bindable var cmvm: CineMateViewModel

    var body: some View {
        RootView(cmvm: cmvm)
    }
}


#Preview {
    ContentView(cmvm: CineMateViewModel())
}
