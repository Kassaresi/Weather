//
//  ContentView.swift
//  Weather
//
//  Created by Alikhan Kassiman on 2025.04.11.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var viewModel = WeatherViewModel()
    
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var showLocationResults = false
    
    @State private var refreshTrigger = UUID()
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                
                VStack(spacing: 0) {
                    searchBar
                    
                    if showLocationResults {
                        locationSearchContent
                    } else {
                        weatherContent
                    }
                }
            }
            .navigationTitle(viewModel.locationName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    refreshButton
                }
            }
            .onAppear {
                viewModel.requestLocationPermission()
            }
        }
    }
    
    // MARK: - UI Components
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(UIColor.systemBackground),
                Color(UIColor.systemBackground).opacity(0.8),
                Color.blue.opacity(0.1)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private var searchBar: some View {
        SearchBar(
            searchText: $searchText,
            isSearching: $isSearching,
            placeholder: "Search for a city",
            onSearch: searchLocation,
            onCancel: {
                showLocationResults = false
            }
        )
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    private var refreshButton: some View {
        Button(action: {
            withAnimation {
                viewModel.refreshWeatherData()
                refreshTrigger = UUID()
            }
        }) {
            Image(systemName: "arrow.clockwise")
        }
    }
    
    private var locationSearchContent: some View {
        VStack {
            if viewModel.isSearching {
                ProgressView()
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else if viewModel.searchResults.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.searchErrorMessage ?? "No locations found")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(viewModel.searchResults) { result in
                            locationResultRow(result)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .transition(.opacity)
    }
    
    private var weatherContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Current Weather
                CurrentWeatherView(
                    state: viewModel.currentWeatherState,
                    onRetry: { viewModel.refreshWeatherData() }
                )
                .id("current-\(refreshTrigger)")
                
                // 5-Day Forecast
                ForecastView(
                    viewModel: viewModel,
                    onRetry: { viewModel.refreshWeatherData() }
                )
                .id("forecast-\(refreshTrigger)")
                
                // Weather Map
                WeatherMapView(
                    mapURL: viewModel.mapURL,
                    selectedLayer: viewModel.selectedMapLayer,
                    onLayerChange: { layer in
                        viewModel.changeMapLayer(to: layer)
                    }
                )
                .id("map-\(refreshTrigger)")
                
                // Air Quality
                AirQualityView(
                    state: viewModel.airQualityState,
                    onRetry: { viewModel.refreshWeatherData() }
                )
                .id("airquality-\(refreshTrigger)")
                
                // Weather Alerts
                AlertsView(
                    state: viewModel.alertsState,
                    onRetry: { viewModel.refreshWeatherData() }
                )
                .id("alerts-\(refreshTrigger)")
            }
            .padding()
            .animation(.default, value: refreshTrigger)
        }
        .refreshable {
            viewModel.refreshWeatherData()
            refreshTrigger = UUID()
        }
    }
    
    // MARK: - Actions
    
    private func searchLocation() {
        guard !searchText.isEmpty else { return }
        
        isSearching = true
        showLocationResults = true
        
        Task {
            await viewModel.searchLocation(query: searchText)
            isSearching = false
        }
    }
    
    private func selectLocation(_ location: GeocodingResult) {
        withAnimation {
            viewModel.selectLocation(location)
            searchText = ""
            showLocationResults = false
            isSearching = false
        }
    }
}

#Preview {
    ContentView()
}

    
private var weatherContent: some View {
    ScrollView {
        VStack(spacing: 16) {
            // Current Weather
            CurrentWeatherView(
                state: viewModel.currentWeatherState,
                onRetry: { viewModel.refreshWeatherData() }
            )
            .id("current-\(refreshTrigger)")
            
            // 5-Day Forecast
            ForecastView(
                viewModel: viewModel,
                onRetry: { viewModel.refreshWeatherData() }
            )
            .id("forecast-\(refreshTrigger)")
            
            // Weather Map
            WeatherMapView(
                mapURL: viewModel.mapURL,
                selectedLayer: viewModel.selectedMapLayer,
                onLayerChange: { layer in
                    viewModel.changeMapLayer(to: layer)
                }
            )
            .id("map-\(refreshTrigger)")
            
            // Air Quality
            AirQualityView(
                state: viewModel.airQualityState,
                onRetry: { viewModel.refreshWeatherData() }
            )
            .id("airquality-\(refreshTrigger)")
            
            // Weather Alerts
            AlertsView(
                state: viewModel.alertsState,
                onRetry: { viewModel.refreshWeatherData() }
            )
            .id("alerts-\(refreshTrigger)")
        }
    }
}
