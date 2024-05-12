//
//  GPXViewTestView.swift
//  DrypotGPX
//
//  Created by Kyuhyun Park on 5/11/24.
//

import SwiftUI

struct GPXViewTestView: View {
    
    @StateObject var model = GPXViewModel()
    
    var body: some View {
        VStack {
            GPXView(model: model)
            Button("Load Sample") {
                print("button update: clicked")
                model.loadSampleTrack()
            }
        }
    }
}

#Preview {
    GPXViewTestView()
}
