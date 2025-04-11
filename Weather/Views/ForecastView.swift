//
//  ForecastView.swift
//  Weather
//
//  Created by Alikhan Kassiman on 2025.04.11.
//

import SwiftUI

struct ForecastView: View {
    @ObservedObject var viewModel: WeatherViewModel
    let onRetry: () -> Void
    
    var body: some View {
        WeatherCard(title: "5-Day Forecast", systemImage: "calendar") {
            switch viewModel.forecastState {
            case .idle:
                EmptyView()
                
            case .loading(let progress):
                LoadingView(
                    progress: progress,
                    text: "Loading forecast data..."
                )
                
            case .success:
                forecastContent
                
            case .failure(let error):
                ErrorView(error: error, retryAction: onRetry)
            }
        }
        .transition(.opacity)
    }
    
    private var forecastContent: some View {
        let dailyForecasts = viewModel.processDailyForecasts()
        
        return VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(dailyForecasts) { forecast in
                        dailyForecastCard(forecast)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
    }
    
    private func dailyForecastCard(_ forecast: DailyForecast) -> some View {
        VStack(spacing: 8) {
            // Day of week
            Text(dayOfWeek(from: forecast.date))
                .font(.headline)
            
            // Date
            Text(shortDate(from: forecast.date))
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Weather icon
            AsyncImage(url: forecast.iconURL) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                } else {
                    Image(systemName: "cloud.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 4)
            
            // Temperature
            VStack(spacing: 4) {
                Text("\(Int(forecast.maxTemp))°")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text("\(Int(forecast.minTemp))°")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Precipitation
            HStack(spacing: 4) {
                Image(systemName: "drop.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Text("\(Int(forecast.precipitationChance * 100))%")
                    .font(.caption)
            }
        }
        .frame(width: 90)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
    
    private func dayOfWeek(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    private func shortDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
}

#Preview {
    let viewModel = WeatherViewModel()
    
    return VStack {
        ForecastView(
            viewModel: viewModel,
            onRetry: {}
        )
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}
