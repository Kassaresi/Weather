//
//  WeatherMapView.swift
//  Weather
//
//  Created by Alikhan Kassiman on 2025.04.11.
//

import SwiftUI

struct WeatherMapView: View {
    let mapURL: URL?
    let selectedLayer: WeatherMapLayer
    let onLayerChange: (WeatherMapLayer) -> Void
    
    @State private var isShowingLayerPicker = false
    
    var body: some View {
        WeatherCard(title: "Weather Map", systemImage: "map") {
            VStack(spacing: 0) {
                // Layer selector
                layerSelector
                
                // Map content
                mapContent
            }
        }
        .transition(.opacity)
    }
    
    private var layerSelector: some View {
        HStack {
            Text(selectedLayer.displayName)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: {
                isShowingLayerPicker.toggle()
            }) {
                HStack {
                    Text("Change")
                        .font(.subheadline)
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                }
                .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .confirmationDialog("Select Map Layer", isPresented: $isShowingLayerPicker, titleVisibility: .visible) {
            ForEach(WeatherMapLayer.allCases) { layer in
                Button(layer.displayName) {
                    onLayerChange(layer)
                }
            }
            
            Button("Cancel", role: .cancel) { }
        }
    }
    
    private var mapContent: some View {
        ZStack {
            if let url = mapURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        loadingMapView
                        
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(8)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                        
                    case .failure:
                        mapErrorView
                        
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                noMapView
            }
        }
        .frame(height: 200)
    }
    
    private var loadingMapView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.2)
                .padding(.bottom, 8)
            
            Text("Loading map...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    private var mapErrorView: some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title)
                .foregroundColor(.orange)
            
            Text("Map unavailable")
                .font(.headline)
            
            Text("Try a different map layer")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    private var noMapView: some View {
        VStack(spacing: 8) {
            Image(systemName: "map")
                .font(.title)
                .foregroundColor(.secondary)
            
            Text("Map unavailable")
                .font(.headline)
            
            Text("No location data available")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

#Preview {
    VStack {
        WeatherMapView(
            mapURL: URL(string: "https://tile.openweathermap.org/map/precipitation_new/5/15/15.png"),
            selectedLayer: .precipitation,
            onLayerChange: { _ in }
        )
        
        WeatherMapView(
            mapURL: nil,
            selectedLayer: .temperature,
            onLayerChange: { _ in }
        )
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}
