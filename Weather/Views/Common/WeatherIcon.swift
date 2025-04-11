//
//  WeatherIcon.swift
//  Weather
//
//  Created by Alikhan Kassiman on 2025.04.11.
//

import SwiftUI

struct WeatherIcon: View {
    let iconURL: URL?
    let description: String
    let size: CGFloat
    
    init(iconURL: URL?, description: String, size: CGFloat = 50) {
        self.iconURL = iconURL
        self.description = description
        self.size = size
    }
    
    var body: some View {
        if let url = iconURL {
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size, height: size)
                } else if phase.error != nil {
                    placeholderIcon
                } else {
                    ProgressView()
                        .frame(width: size, height: size)
                }
            }
        } else {
            placeholderIcon
        }
    }
    
    private var placeholderIcon: some View {
        Image(systemName: "cloud.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .foregroundColor(.gray)
    }
}

#Preview {
    VStack(spacing: 20) {
        WeatherIcon(
            iconURL: URL(string: "https://openweathermap.org/img/wn/01d@2x.png"),
            description: "Clear sky",
            size: 100
        )
        
        WeatherIcon(
            iconURL: nil,
            description: "Unknown",
            size: 50
        )
    }
    .padding()
}
