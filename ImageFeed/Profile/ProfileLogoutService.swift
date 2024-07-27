//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Bakgeldi Alkhabay on 22.07.2024.
//

import Foundation
import WebKit
import Kingfisher

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
      
    private init() { }

    func logout() {
        cleanCookies()
        cleanUsersData()
        switchToSplashViewController()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func cleanUsersData() {
        OAuth2TokenStorage.shared.deleteToken()
        
        ProfileService.shared.cleanProfile()
        ProfileImageService.shared.cleanAvatarURL()
        ImagesListService.shared.cleanPhotos()
        
        let cache = ImageCache.default
        cache.clearMemoryCache()
        cache.clearDiskCache()
    }
    
    private func switchToSplashViewController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
    }
}
