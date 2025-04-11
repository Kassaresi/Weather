//
//  SearchBar.swift
//  Weather
//
//  Created by Alikhan Kassiman on 2025.04.11.
//

import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String
    @Binding var isSearching: Bool
    let placeholder: String
    let onSearch: () -> Void
    let onCancel: () -> Void
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField(placeholder, text: $searchText)
                    .focused($isFocused)
                    .disableAutocorrection(true)
                    .submitLabel(.search)
                    .onSubmit {
                        onSearch()
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(10)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(10)
            .onTapGesture {
                isSearching = true
                isFocused = true
            }
            
            if isSearching {
                Button("Cancel") {
                    searchText = ""
                    isSearching = false
                    onCancel()
                    isFocused = false
                    
                    // Dismiss keyboard
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                   to: nil, from: nil, for: nil)
                }
                .transition(.move(edge: .trailing))
            }
        }
        .animation(.default, value: isSearching)
        .animation(.default, value: searchText)
    }
}

#Preview {
    VStack {
        SearchBar(
            searchText: .constant("London"),
            isSearching: .constant(false),
            placeholder: "Search for a city",
            onSearch: {},
            onCancel: {}
        )
        .padding(.vertical)
        
        SearchBar(
            searchText: .constant(""),
            isSearching: .constant(true),
            placeholder: "Search for a city",
            onSearch: {},
            onCancel: {}
        )
        .padding(.vertical)
    }
    .padding()
}
