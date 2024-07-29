//
//  ProfileViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Bakgeldi Alkhabay on 28.07.2024.
//

import ImageFeed
import Foundation

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ImageFeed.ProfilePresenterProtocol?
    
    private(set) var displayProfileDetailsCalled = false
    private(set) var displayProfileDetailsName: String?
    private(set) var displayProfileDetailsUsername: String?
    private(set) var displayProfileDetailsDescription: String?
    
    private(set) var displayAvatarCalled = false
    private(set) var displayAvatarImageURL: String?
    
    func displayProfileDetails(name: String, username: String, description: String) {
        displayProfileDetailsCalled = true
        displayProfileDetailsName = name
        displayProfileDetailsUsername = username
        displayProfileDetailsDescription = description
    }
    
    func displayAvatar(imageURL: String) {
        displayAvatarCalled = true
        displayAvatarImageURL = imageURL
    }
}
