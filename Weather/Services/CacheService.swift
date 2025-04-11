//
//  CacheService.swift
//  Weather
//
//  Created by Alikhan Kassiman on 2025.04.11.
//

import Foundation

class CacheService {
    static let shared = CacheService()
    
    private let cache = NSCache<NSString, CacheEntry>()
    private let cacheDuration: TimeInterval = 60 * 15 // 15 minutes
    
    private init() {
        cache.countLimit = 50 // Limit number of cached items
    }
    
    func cacheData<T: Codable>(_ data: T, for key: String) {
        let entry = CacheEntry(data: data, timestamp: Date())
        cache.setObject(entry, forKey: key as NSString)
    }
    
    func retrieveData<T: Codable>(for key: String) -> T? {
        guard let entry = cache.object(forKey: key as NSString) else {
            return nil
        }
        
        if Date().timeIntervalSince(entry.timestamp) > cacheDuration {
            cache.removeObject(forKey: key as NSString)
            return nil
        }
        
        return entry.data as? T
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
    
    func isCacheValid(for key: String) -> Bool {
        guard let entry = cache.object(forKey: key as NSString) else {
            return false
        }
        
        return Date().timeIntervalSince(entry.timestamp) <= cacheDuration
    }
    
    func cacheKey(for endpoint: APIService.Endpoint) -> String {
        switch endpoint {
        case .currentWeather(let lat, let lon):
            return "current-\(lat)-\(lon)"
        case .forecast(let lat, let lon):
            return "forecast-\(lat)-\(lon)"
        case .airQuality(let lat, let lon):
            return "airquality-\(lat)-\(lon)"
        case .alerts(let lat, let lon):
            return "alerts-\(lat)-\(lon)"
        case .geocoding(let query, _):
            return "geocoding-\(query)"
        case .weatherMap(let layer, let zoom, let x, let y):
            return "map-\(layer.rawValue)-\(zoom)-\(x)-\(y)"
        }
    }
}

class CacheEntry: NSObject {
    let data: Any
    let timestamp: Date
    
    init(data: Any, timestamp: Date) {
        self.data = data
        self.timestamp = timestamp
        super.init()
    }
}
