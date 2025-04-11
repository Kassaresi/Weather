//
//  AlertsView.swift
//  Weather
//
//  Created by Alikhan Kassiman on 2025.04.11.
//

import SwiftUI

struct AlertsView: View {
    let state: LoadingState<AlertsResponse>
    let onRetry: () -> Void
    
    @State private var expandedAlertID: UUID?
    
    var body: some View {
        WeatherCard(title: "Weather Alerts", systemImage: "exclamationmark.triangle") {
            switch state {
            case .idle:
                EmptyView()
                
            case .loading(let progress):
                LoadingView(
                    progress: progress,
                    text: "Checking for weather alerts..."
                )
                
            case .success(let alertsResponse):
                if let alerts = alertsResponse.alerts, !alerts.isEmpty {
                    alertsContent(alerts)
                } else {
                    noAlertsView()
                }
                
            case .failure(let error):
                ErrorView(error: error, retryAction: onRetry)
            }
        }
        .transition(.opacity)
    }
    
    @ViewBuilder
    private func alertsContent(_ alerts: [WeatherAlert]) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(alerts) { alert in
                    alertView(alert)
                    
                    if alert.id != alerts.last?.id {
                        Divider()
                            .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .frame(maxHeight: 300)
    }
    
    private func alertView(_ alert: WeatherAlert) -> some View {
        let isExpanded = alert.id == expandedAlertID
        
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                alertIcon(for: alert.event)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(alert.event)
                        .font(.headline)
                    
                    Text("\(formatDate(alert.startDate)) - \(formatDate(alert.endDate))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        expandedAlertID = isExpanded ? nil : alert.id
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
            }
            
            if isExpanded {
                Text(alert.description)
                    .font(.subheadline)
                    .lineLimit(nil)
                    .padding(.top, 4)
                
                if let tags = alert.tags, !tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.blue.opacity(0.2))
                                    )
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding(16)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                expandedAlertID = isExpanded ? nil : alert.id
            }
        }
    }
    
    private func noAlertsView() -> some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 36))
                .foregroundColor(.green)
                .padding(.top, 16)
            
            Text("No Weather Alerts")
                .font(.headline)
            
            Text("The weather is clear in this area")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    private func alertIcon(for eventType: String) -> some View {
        let iconName: String
        let iconColor: Color
        
        let lowercasedEvent = eventType.lowercased()
        
        if lowercasedEvent.contains("flood") {
            iconName = "drop.fill"
            iconColor = .blue
        } else if lowercasedEvent.contains("storm") || lowercasedEvent.contains("thunder") {
            iconName = "cloud.bolt.fill"
            iconColor = .yellow
        } else if lowercasedEvent.contains("wind") || lowercasedEvent.contains("tornado") {
            iconName = "wind"
            iconColor = .orange
        } else if lowercasedEvent.contains("snow") || lowercasedEvent.contains("blizzard") {
            iconName = "snow"
            iconColor = .cyan
        } else if lowercasedEvent.contains("heat") {
            iconName = "thermometer.sun.fill"
            iconColor = .red
        } else if lowercasedEvent.contains("cold") || lowercasedEvent.contains("freeze") {
            iconName = "thermometer.snowflake"
            iconColor = .blue
        } else {
            iconName = "exclamationmark.triangle.fill"
            iconColor = .orange
        }
        
        return Image(systemName: iconName)
            .font(.title3)
            .foregroundColor(iconColor)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: date)
    }
}

#Preview {
    VStack {
        AlertsView(
            state: .loading(progress: 0.8),
            onRetry: {}
        )
        
        AlertsView(
            state: .failure(WeatherError.networkError(NSError(domain: "", code: -1009, userInfo: nil))),
            onRetry: {}
        )
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}
