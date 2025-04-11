//
//  WeatherData.swift
//  Weather
//
//  Created by Alikhan Kassiman on 2025.04.11.
//

import Foundation

struct CurrentWeather: Identifiable, Codable, Equatable {
    let id = UUID()
    let coord: Coordinates
    let weather: [WeatherCondition]
    let base: String
    let main: MainWeatherData
    let visibility: Int
    let wind: Wind
    let clouds: Clouds
    let dt: TimeInterval
    let sys: Sys
    let timezone: Int
    let name: String
    
    var date: Date {
        return Date(timeIntervalSince1970: dt)
    }
    
    var iconURL: URL? {
        guard let condition = weather.first else { return nil }
        return URL(string: "https://openweathermap.org/img/wn/\(condition.icon)@2x.png")
    }
    
    static func == (lhs: CurrentWeather, rhs: CurrentWeather) -> Bool {
        return lhs.dt == rhs.dt &&
               lhs.name == rhs.name &&
               lhs.main == rhs.main &&
               lhs.weather == rhs.weather
    }
}

// MARK: - 5-Day Forecast
struct ForecastResponse: Codable, Equatable {
    let list: [ForecastItem]
    let city: City
}

struct ForecastItem: Identifiable, Codable, Equatable {
    let id = UUID()
    let dt: TimeInterval
    let main: MainWeatherData
    let weather: [WeatherCondition]
    let clouds: Clouds
    let wind: Wind
    let visibility: Int
    let pop: Double
    let dt_txt: String
    
    var date: Date {
        return Date(timeIntervalSince1970: dt)
    }
    
    var iconURL: URL? {
        guard let condition = weather.first else { return nil }
        return URL(string: "https://openweathermap.org/img/wn/\(condition.icon)@2x.png")
    }
    
    static func == (lhs: ForecastItem, rhs: ForecastItem) -> Bool {
        return lhs.dt == rhs.dt &&
               lhs.dt_txt == rhs.dt_txt &&
               lhs.main == rhs.main &&
               lhs.weather == rhs.weather
    }
}

// MARK: - Air Quality
struct AirQualityResponse: Codable, Equatable {
    let list: [AirQualityData]
}

struct AirQualityData: Identifiable, Codable, Equatable {
    let id = UUID()
    let main: AirQualityMain
    let components: AirQualityComponents
    let dt: TimeInterval
    
    var date: Date {
        return Date(timeIntervalSince1970: dt)
    }
    
    var qualityLevel: String {
        switch main.aqi {
        case 1: return "Good"
        case 2: return "Fair"
        case 3: return "Moderate"
        case 4: return "Poor"
        case 5: return "Very Poor"
        default: return "Unknown"
        }
    }
    
    var qualityColor: String {
        switch main.aqi {
        case 1: return "green"
        case 2: return "blue"
        case 3: return "yellow"
        case 4: return "orange"
        case 5: return "red"
        default: return "gray"
        }
    }
    
    static func == (lhs: AirQualityData, rhs: AirQualityData) -> Bool {
        return lhs.dt == rhs.dt &&
               lhs.main == rhs.main &&
               lhs.components == rhs.components
    }
}

struct AirQualityMain: Codable, Equatable {
    let aqi: Int
}

struct AirQualityComponents: Codable, Equatable {
    let co: Double
    let no: Double
    let no2: Double
    let o3: Double
    let so2: Double
    let pm2_5: Double
    let pm10: Double
    let nh3: Double
}

// MARK: - Weather Alerts
struct AlertsResponse: Codable, Equatable {
    let alerts: [WeatherAlert]?
    let city: City
}

struct WeatherAlert: Identifiable, Codable, Equatable {
    let id = UUID()
    let sender_name: String
    let event: String
    let start: TimeInterval
    let end: TimeInterval
    let description: String
    let tags: [String]?
    
    var startDate: Date {
        return Date(timeIntervalSince1970: start)
    }
    
    var endDate: Date {
        return Date(timeIntervalSince1970: end)
    }
    
    static func == (lhs: WeatherAlert, rhs: WeatherAlert) -> Bool {
        return lhs.start == rhs.start &&
               lhs.end == rhs.end &&
               lhs.event == rhs.event &&
               lhs.sender_name == rhs.sender_name
    }
}

// MARK: - Common Components
struct Coordinates: Codable, Equatable {
    let lon: Double
    let lat: Double
}

struct WeatherCondition: Codable, Equatable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct MainWeatherData: Codable, Equatable {
    let temp: Double
    let feels_like: Double
    let temp_min: Double
    let temp_max: Double
    let pressure: Int
    let humidity: Int
    let sea_level: Int?
    let grnd_level: Int?
}

struct Wind: Codable, Equatable {
    let speed: Double
    let deg: Int
    let gust: Double?
}

struct Clouds: Codable, Equatable {
    let all: Int
}

struct Sys: Codable, Equatable {
    let type: Int?
    let id: Int?
    let country: String
    let sunrise: TimeInterval
    let sunset: TimeInterval
}

struct City: Codable, Equatable {
    let id: Int
    let name: String
    let coord: Coordinates
    let country: String
    let population: Int
    let timezone: Int
    let sunrise: TimeInterval
    let sunset: TimeInterval
}

// MARK: - Geocoding
struct GeocodingResult: Identifiable, Codable, Equatable {
    let id = UUID()
    let name: String
    let lat: Double
    let lon: Double
    let country: String
    let state: String?
    
    var displayName: String {
        if let state = state {
            return "\(name), \(state), \(country)"
        }
        return "\(name), \(country)"
    }
    
    static func == (lhs: GeocodingResult, rhs: GeocodingResult) -> Bool {
        return lhs.name == rhs.name &&
               lhs.lat == rhs.lat &&
               lhs.lon == rhs.lon &&
               lhs.country == rhs.country &&
               lhs.state == rhs.state
    }
}

// MARK: - Daily Forecast (processed)
struct DailyForecast: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let maxTemp: Double
    let minTemp: Double
    let precipitationChance: Double
    let iconURL: URL?
    let description: String
    
    static func == (lhs: DailyForecast, rhs: DailyForecast) -> Bool {
        return lhs.date == rhs.date &&
               lhs.maxTemp == rhs.maxTemp &&
               lhs.minTemp == rhs.minTemp &&
               lhs.precipitationChance == rhs.precipitationChance &&
               lhs.description == rhs.description
    }
}

// MARK: - Weather Map Layer Type
enum WeatherMapLayer: String, CaseIterable, Identifiable {
    case precipitation = "precipitation_new"
    case temperature = "temp_new"
    case pressure = "pressure_new"
    case wind = "wind_new"
    case clouds = "clouds_new"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .precipitation: return "Precipitation"
        case .temperature: return "Temperature"
        case .pressure: return "Pressure"
        case .wind: return "Wind Speed"
        case .clouds: return "Cloud Cover"
        }
    }
}
