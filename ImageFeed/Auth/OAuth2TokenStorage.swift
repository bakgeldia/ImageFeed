//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Bakgeldi Alkhabay on 09.07.2024.
//

import UIKit
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared =  OAuth2TokenStorage()
    
    private init() {}
    
    private let tokenKey = "access_token_15"
    
    func saveToken(_ token: String){
        KeychainWrapper.standard.set(token, forKey: tokenKey)
    }
    
    func getToken() -> String? {
        return KeychainWrapper.standard.string(forKey: tokenKey)
    }
    
    func deleteToken() {
        KeychainWrapper.standard.removeObject(forKey: tokenKey)
    }
}
