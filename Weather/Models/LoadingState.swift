//
//  LoadingState.swift
//  Weather
//
//  Created by Alikhan Kassiman on 2025.04.11.
//

import Foundation

enum LoadingState<T: Equatable>: Equatable {
    case idle
    case loading(progress: Double? = nil)
    case success(T)
    case failure(Error)
    
    var isLoading: Bool {
        switch self {
        case .loading:
            return true
        default:
            return false
        }
    }
    
    var value: T? {
        switch self {
        case .success(let value):
            return value
        default:
            return nil
        }
    }
    
    var error: Error? {
        switch self {
        case .failure(let error):
            return error
        default:
            return nil
        }
    }
    
    var progress: Double? {
        switch self {
        case .loading(let progress):
            return progress
        default:
            return nil
        }
    }
    
    static func == (lhs: LoadingState<T>, rhs: LoadingState<T>) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.loading(let lhsProgress), .loading(let rhsProgress)):
            return lhsProgress == rhsProgress
        case (.success(let lhsValue), .success(let rhsValue)):
            return lhsValue == rhsValue
        case (.failure, .failure):
            return true
        default:
            return false
        }
    }
}
