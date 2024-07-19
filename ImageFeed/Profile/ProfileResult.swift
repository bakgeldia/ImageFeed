//
//  ProfileResult.swift
//  ImageFeed
//
//  Created by Bakgeldi Alkhabay on 19.07.2024.
//

import UIKit

struct ProfileResult: Codable {
    let username: String
    let name: String
    let bio: String?
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}
