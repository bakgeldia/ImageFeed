//
//  UserResult.swift
//  ImageFeed
//
//  Created by Bakgeldi Alkhabay on 19.07.2024.
//

import UIKit

struct UserResult: Codable {
    struct ProfileImage: Codable {
        let small: String
    }
    let profile_image: ProfileImage
}
