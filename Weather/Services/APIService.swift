//
//  APIService.swift
//  Weather
//
//  Created by Alikhan Kassiman on 2025.04.11.
//

import Foundation

class APIService {
    static let shared = APIService()
    
    private let baseURL = "https://api.openweathermap.org/data/2.5"
    private let geoURL = "https://api.openweathermap.org/geo/1.0"
    private let apiKey = "" // Add your API key here
    
    private let decoder: JSONDecoder
    
    private init() {
        decoder = JSONDecoder()
    }
    
    // MARK: - API Endpoints
    
    enum Endpoint {
        case currentWeather(lat: Double, lon: Double)
        case forecast(lat: Double, lon: Double)
        case airQuality(lat: Double, lon: Double)
        case alerts(lat: Double, lon: Double)
        case geocoding(query: String, limit: Int)
        case weatherMap(layer: WeatherMapLayer, zoom: Int, x: Int, y: Int)
        
        var path: String {
            switch self {
            case .currentWeather:
                return "/weather"
            case .forecast:
                return "/forecast"
            case .airQuality:
                return "/air_pollution"
            case .alerts:
                return "/onecall"
            case .geocoding:
                return "/direct"
            case .weatherMap(let layer, _, _, _):
                return "/maps/\(layer.rawValue)"
            }
        }
        
        var baseURL: String {
            switch self {
            case .geocoding:
                return "https://api.openweathermap.org/geo/1.0"
            case .weatherMap:
                return "https://tile.openweathermap.org"
            default:
                return "https://api.openweathermap.org/data/2.5"
            }
        }
        
        var queryItems: [URLQueryItem] {
            var items = [URLQueryItem]()
            
            switch self {
            case .currentWeather(let lat, let lon),
                 .forecast(let lat, let lon),
                 .airQuality(let lat, let lon):
                items.append(contentsOf: [
                    URLQueryItem(name: "lat", value: "\(lat)"),
                    URLQueryItem(name: "lon", value: "\(lon)"),
                    URLQueryItem(name: "units", value: "metric")
                ])
                
            case .alerts(let lat, let lon):
                items.append(contentsOf: [
                    URLQueryItem(name: "lat", value: "\(lat)"),
                    URLQueryItem(name: "lon", value: "\(lon)"),
                    URLQueryItem(name: "exclude", value: "current,minutely,hourly,daily"),
                    URLQueryItem(name: "units", value: "metric")
                ])
                
            case .geocoding(let query, let limit):
                items.append(contentsOf: [
                    URLQueryItem(name: "q", value: query),
                    URLQueryItem(name: "limit", value: "\(limit)")
                ])
                
            case .weatherMap:
                return []
            }
            
            return items
        }
        
        func url(with apiKey: String) -> URL? {
            var components = URLComponents(string: baseURL + path)
            
            // Add query items for all endpoints except weather map tiles
            if case .weatherMap(_, let zoom, let x, let y) = self {
                components = URLComponents(string: "\(baseURL)\(path)/\(zoom)/\(x)/\(y).png")
            } else {
                var items = queryItems
                items.append(URLQueryItem(name: "appid", value: apiKey))
                components?.queryItems = items
            }
            
            return components?.url
        }
    }
    
    // MARK: - API Requests
    
    /// Fetch current weather data
    @MainActor
    func fetchCurrentWeather(lat: Double, lon: Double) async throws -> CurrentWeather {
        let endpoint = Endpoint.currentWeather(lat: lat, lon: lon)
        let cacheKey = CacheService.shared.cacheKey(for: endpoint)
        
        if let cached: CurrentWeather = CacheService.shared.retrieveData(for: cacheKey) {
            return cached
        }
        
        let weather: CurrentWeather = try await fetchData(from: endpoint)
        CacheService.shared.cacheData(weather, for: cacheKey)
        return weather
    }
    
    /// Fetch 5-day forecast
    @MainActor
    func fetchForecast(lat: Double, lon: Double) async throws -> ForecastResponse {
        let endpoint = Endpoint.forecast(lat: lat, lon: lon)
        let cacheKey = CacheService.shared.cacheKey(for: endpoint)
        
        if let cached: ForecastResponse = CacheService.shared.retrieveData(for: cacheKey) {
            return cached
        }
        
        let forecast: ForecastResponse = try await fetchData(from: endpoint)
        CacheService.shared.cacheData(forecast, for: cacheKey)
        return forecast
    }
    
    /// Fetch air quality data
    @MainActor
    func fetchAirQuality(lat: Double, lon: Double) async throws -> AirQualityResponse {
        let endpoint = Endpoint.airQuality(lat: lat, lon: lon)
        let cacheKey = CacheService.shared.cacheKey(for: endpoint)
        
        if let cached: AirQualityResponse = CacheService.shared.retrieveData(for: cacheKey) {
            return cached
        }
        
        let airQuality: AirQualityResponse = try await fetchData(from: endpoint)
        CacheService.shared.cacheData(airQuality, for: cacheKey)
        return airQuality
    }
    
    /// Fetch weather alerts
    @MainActor
    func fetchAlerts(lat: Double, lon: Double) async throws -> AlertsResponse {
        let endpoint = Endpoint.alerts(lat: lat, lon: lon)
        let cacheKey = CacheService.shared.cacheKey(for: endpoint)
        
        if let cached: AlertsResponse = CacheService.shared.retrieveData(for: cacheKey) {
            return cached
        }
        
        // Temporarily get current weather to build a fake alerts response
        // This is because onecall endpoint requires a separate subscription
        let weather = try await fetchCurrentWeather(lat: lat, lon: lon)
        
        let city = City(
            id: Int.random(in: 1000...9999),
            name: weather.name,
            coord: weather.coord,
            country: weather.sys.country,
            population: 0,
            timezone: weather.timezone,
            sunrise: weather.sys.sunrise,
            sunset: weather.sys.sunset
        )
        
        let alertsResponse = AlertsResponse(alerts: nil, city: city)
        CacheService.shared.cacheData(alertsResponse, for: cacheKey)
        return alertsResponse
    }
    
    /// Fetch geocoding results for a city name
    @MainActor
    func fetchGeocodingResults(for query: String, limit: Int = 5) async throws -> [GeocodingResult] {
        let endpoint = Endpoint.geocoding(query: query, limit: limit)
        let cacheKey = CacheService.shared.cacheKey(for: endpoint)
        
        if let cached: [GeocodingResult] = CacheService.shared.retrieveData(for: cacheKey) {
            return cached
        }
        
        let results: [GeocodingResult] = try await fetchData(from: endpoint)
        CacheService.shared.cacheData(results, for: cacheKey)
        return results
    }
    
    /// Get weather map image URL
    func getWeatherMapURL(layer: WeatherMapLayer, zoom: Int = 5, x: Int, y: Int) -> URL? {
        let urlString = "https://tile.openweathermap.org/map/\(layer.rawValue)/\(zoom)/\(x)/\(y).png?appid=\(apiKey)"
        return URL(string: urlString)
    }
    
    // MARK: - Generic Network Request
    
    /// Generic method to fetch and decode data from a specific endpoint
    @MainActor
    private func fetchData<T: Decodable>(from endpoint: Endpoint) async throws -> T {
        guard let url = endpoint.url(with: apiKey) else {
            throw WeatherError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw WeatherError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
                   let message = errorResponse["message"] {
                    throw WeatherError.apiError(message)
                }
                throw WeatherError.apiError("Status code: \(httpResponse.statusCode)")
            }
            
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                print("Decoding error: \(error)")
                throw WeatherError.invalidData
            }
        } catch let error as WeatherError {
            throw error
        } catch {
            throw WeatherError.networkError(error)
        }
    }
}
