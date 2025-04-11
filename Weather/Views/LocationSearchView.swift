//
//  LocationSearchView.swift
//  Weather
//
//  Created by Alikhan Kassiman on 2025.04.11.
//

import SwiftUI

struct LocationSearchView: View {
    @ObservedObject var viewModel: WeatherViewModel
    @Binding var searchText: String
    @Binding var isSearching: Bool
    @Binding var showLocationResults: Bool
    
    var onLocationSelect: (GeocodingResult) -> Void
    
    var body: some View {
        VStack {
            if viewModel.isSearching {
                searchingView
            } else if let errorMessage = viewModel.searchErrorMessage {
                errorView(errorMessage)
            } else if viewModel.searchResults.isEmpty {
                emptyResultsView
            } else {
                searchResultsList
            }
        }
        .transition(.opacity)
    }
    
    private var searchingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .padding()
            
            Text("Searching locations...")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: 300)
        .padding()
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32))
                .foregroundColor(.orange)
            
            Text(message)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: 300)
        .padding()
    }
    
    private var emptyResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 32))
                .foregroundColor(.secondary)
            
            Text("No locations found")
                .foregroundColor(.secondary)
            
            Text("Try another search term")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: 300)
        .padding()
    }
    
    private var searchResultsList: some View {
        ScrollView {
            LazyVStack(spacing: 2) {
                ForEach(viewModel.searchResults) { result in
                    locationResultRow(result)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func locationResultRow(_ result: GeocodingResult) -> some View {
        Button(action: {
            onLocationSelect(result)
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.name)
                        .font(.headline)
                    
                    Text(result.country + (result.state != nil ? ", \(result.state!)" : ""))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
    }
}

#Preview {
    let viewModel = WeatherViewModel()
    
    return VStack {
        LocationSearchView(
            viewModel: viewModel,
            searchText: .constant("London"),
            isSearching: .constant(true),
            showLocationResults: .constant(true),
            onLocationSelect: { _ in }
        )
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}
