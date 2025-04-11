//
//  LoadingView.swift
//  Weather
//
//  Created by Alikhan Kassiman on 2025.04.11.
//

import SwiftUI

struct LoadingView: View {
    let progress: Double?
    let text: String
    
    init(progress: Double? = nil, text: String = "Loading...") {
        self.progress = progress
        self.text = text
    }
    
    var body: some View {
        VStack(spacing: 12) {
            if let progress = progress {
                ProgressView(value: progress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(width: 150)
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
            }
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color(.systemBackground).opacity(0.8))
    }
}

#Preview {
    VStack(spacing: 20) {
        LoadingView()
        LoadingView(progress: 0.3, text: "Fetching forecast data...")
        LoadingView(progress: 0.7, text: "Almost there...")
    }
    .padding()
}
