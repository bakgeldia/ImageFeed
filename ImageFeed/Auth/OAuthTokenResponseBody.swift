//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Bakgeldi Alkhabay on 09.07.2024.
//

import UIKit

struct OAuthTokenResponseBody: Decodable {
    let access_token: String
    let token_type: String
    let scope: String
    let created_at: Int
    
    enum CodingKeys: String, CodingKey {
        case access_token = "access_token"
        case token_type = "token_type"
        case scope = "scope"
        case created_at = "created_at"
    }
}
