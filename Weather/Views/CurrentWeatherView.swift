//
//  CurrentWeatherView.swift
//  Weather
//
//  Created by Alikhan Kassiman on 2025.04.11.
//

import SwiftUI

struct CurrentWeatherView: View {
    let state: LoadingState<CurrentWeather>
    let onRetry: () -> Void
    
    var body: some View {
        WeatherCard(title: "Current Weather", systemImage: "thermometer") {
            switch state {
            case .idle:
                EmptyView()
                
            case .loading(let progress):
                LoadingView(
                    progress: progress,
                    text: "Loading current conditions..."
                )
                
            case .success(let weather):
                currentWeatherContent(weather)
                
            case .failure(let error):
                ErrorView(error: error, retryAction: onRetry)
            }
        }
        .transition(.opacity)
    }
    
    @ViewBuilder
    private func currentWeatherContent(_ weather: CurrentWeather) -> some View {
        VStack(spacing: 16) {
            // Location and date
            VStack(spacing: 4) {
                Text(weather.name)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(formatDate(weather.date))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 8)
            
            // Current temperature and condition
            HStack(alignment: .center, spacing: 16) {
                Text("\(Int(weather.main.temp))°")
                    .font(.system(size: 64, weight: .medium))
                    .foregroundColor(.primary)
                
                AsyncImage(url: weather.iconURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 70, height: 70)
                    } else {
                        Image(systemName: "cloud.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 70, height: 70)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Text(weather.weather.first?.description.capitalized ?? "")
                .font(.title3)
                .foregroundColor(.primary)
            
            // Additional weather details
            HStack(spacing: 30) {
                weatherDetail(
                    icon: "thermometer",
                    value: "Feels like \(Int(weather.main.feels_like))°"
                )
                
                weatherDetail(
                    icon: "humidity",
                    value: "\(weather.main.humidity)%"
                )
                
                weatherDetail(
                    icon: "wind",
                    value: "\(Int(weather.wind.speed)) m/s"
                )
            }
            .padding(.vertical, 8)
            
            Divider()
                .padding(.horizontal, 32)
            
            // Sun times
            HStack(spacing: 40) {
                VStack(spacing: 4) {
                    Image(systemName: "sunrise.fill")
                        .font(.title3)
                        .foregroundColor(.orange)
                    
                    Text("Sunrise")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(formatTime(Date(timeIntervalSince1970: weather.sys.sunrise)))
                        .font(.subheadline)
                        .bold()
                }
                
                VStack(spacing: 4) {
                    Image(systemName: "sunset.fill")
                        .font(.title3)
                        .foregroundColor(.orange)
                    
                    Text("Sunset")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(formatTime(Date(timeIntervalSince1970: weather.sys.sunset)))
                        .font(.subheadline)
                        .bold()
                }
            }
            .padding(.vertical, 8)
        }
        .padding(.bottom, 16)
    }
    
    private func weatherDetail(icon: String, value: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.subheadline)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

#Preview {
    VStack {
        CurrentWeatherView(
            state: .loading(progress: 0.5),
            onRetry: {}
        )
        
        CurrentWeatherView(
            state: .failure(WeatherError.networkError(NSError(domain: "", code: -1009, userInfo: nil))),
            onRetry: {}
        )
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}
