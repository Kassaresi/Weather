//
//  WeatherError.swift
//  Weather
//
//  Created by Alikhan Kassiman on 2025.04.11.
//

import Foundation

enum WeatherError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidData
    case networkError(Error)
    case apiError(String)
    case noLocationFound
    case locationServicesDisabled
    case locationPermissionDenied
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL. Please try again."
        case .invalidResponse:
            return "Invalid response from server. Please try again later."
        case .invalidData:
            return "The data received from the server was invalid. Please try again."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .apiError(let message):
            return "API error: \(message)"
        case .noLocationFound:
            return "No location found. Please try a different search term."
        case .locationServicesDisabled:
            return "Location services are disabled. Please enable them in Settings."
        case .locationPermissionDenied:
            return "Location permission denied. Please update in Settings."
        case .unknown:
            return "An unknown error occurred. Please try again."
        }
    }
}
