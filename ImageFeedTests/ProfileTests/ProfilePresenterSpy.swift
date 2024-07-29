//
//  ProfilePresenterSpy.swift
//  ImageFeedTests
//
//  Created by Bakgeldi Alkhabay on 28.07.2024.
//

import Foundation
import ImageFeed

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ImageFeed.ProfileViewControllerProtocol?
    
    private(set) var viewDidLoadCalled = false
    private(set) var updateAvatarCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func updateAvatar() {
        updateAvatarCalled = true
    }
}
