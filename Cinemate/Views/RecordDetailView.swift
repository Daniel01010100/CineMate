//
//  RecordDetailView.swift
//  Cinemate
//
//  Created by YUDONG LU on 29/9/2025.
//

import SwiftUI

struct RecordDetailView: View {
    let record: MovieRecords
    @State private var _dateWatched: Date? = nil
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    RecordDetailView(record: .init())
}
