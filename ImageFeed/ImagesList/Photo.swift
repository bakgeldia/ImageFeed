//
//  Photo.swift
//  ImageFeed
//
//  Created by Bakgeldi Alkhabay on 20.07.2024.
//

import UIKit

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}
