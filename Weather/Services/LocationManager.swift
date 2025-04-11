//
//  LocationManager.swift
//  Weather
//
//  Created by Alikhan Kassiman on 2025.04.11.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    private var geocoder = CLGeocoder()
    
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var locationName: String = "Loading location..."
    @Published var searchResults = [GeocodingResult]()
    @Published var isSearching = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        authorizationStatus = locationManager.authorizationStatus
        
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    @MainActor
    func getPlaceName(for location: CLLocation) async -> String {
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            guard let placemark = placemarks.first else {
                return "Unknown Location"
            }
            
            if let locality = placemark.locality {
                return locality
            } else if let subLocality = placemark.subLocality {
                return subLocality
            } else if let administrativeArea = placemark.administrativeArea {
                return administrativeArea
            } else {
                return "Unknown Location"
            }
        } catch {
            print("Error getting location name: \(error)")
            return "Unknown Location"
        }
    }
    
    @MainActor
    func searchLocations(query: String) async {
        errorMessage = nil
        
        guard !query.isEmpty else {
            searchResults = []
            isSearching = false
            return
        }
        
        isSearching = true
        
        do {
            let results = try await APIService.shared.fetchGeocodingResults(for: query)
            searchResults = results
            
            if results.isEmpty {
                errorMessage = "No locations found for '\(query)'"
            }
        } catch {
            // Handle all errors internally
            print("Search error: \(error)")
            errorMessage = "Unable to search for locations"
            searchResults = []
        }
        
        isSearching = false
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            errorMessage = "Location services are disabled. Please enable them in Settings."
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        if let currentLocation = self.location {
            let distance = location.distance(from: currentLocation)
            if distance < 500 { // Less than 500 meters
                return
            }
        }
        
        self.location = location
        
        Task {
            locationName = await getPlaceName(for: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                errorMessage = "Location permission denied. Please update in Settings."
            case .locationUnknown:
                errorMessage = "Unable to determine your location. Please try again later."
            default:
                errorMessage = "Location error: \(error.localizedDescription)"
            }
        } else {
            errorMessage = "Location error: \(error.localizedDescription)"
        }
    }
}
