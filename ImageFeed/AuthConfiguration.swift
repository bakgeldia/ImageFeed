//
//  Constants.swift
//  ImageFeed
//
//  Created by Bakgeldi Alkhabay on 05.07.2024.
//

import UIKit

enum Constants {
    static let accessKey = "MCA9L82kWf3pOZ9Fd2czjLczq8tXjFnmskg9lf2dnpA"
    static let secretKey = "VA-ueIFlo0CpHxgXeKoBDoemdl9T8uZJtRRTWq-gDWk"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let baseURL = "https://api.unsplash.com"
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let baseURL: String
    let authURLString: String

    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, baseURL: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.baseURL = baseURL
        self.authURLString = authURLString
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: Constants.accessKey,
                                 secretKey: Constants.secretKey,
                                 redirectURI: Constants.redirectURI,
                                 accessScope: Constants.accessScope,
                                 authURLString: Constants.unsplashAuthorizeURLString,
                                 baseURL: Constants.baseURL)
    }
}
