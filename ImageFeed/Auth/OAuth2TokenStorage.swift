//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Bakgeldi Alkhabay on 09.07.2024.
//

import UIKit
import SwiftKeychainWrapper

class OAuth2TokenStorage {
    static let shared =  OAuth2TokenStorage()
    
    private init() {}
    
    private let tokenKey = "access_token_8"
    
    func saveToken(_ token: String){
        let isSuccess = KeychainWrapper.standard.set(token, forKey: tokenKey)
        guard isSuccess else {
            print("Error: Failed to save the token in the keychain")
            return
        }
    }
    
    func getToken() -> String? {
        return KeychainWrapper.standard.string(forKey: tokenKey)
    }
    
    func deleteToken() {
        let removeSuccessful = KeychainWrapper.standard.removeObject(forKey: tokenKey)
        if !removeSuccessful {
            print("Error: Failed to delete the token from the Keychain")
        }
    }
}
