//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Bakgeldi Alkhabay on 28.07.2024.
//

import UIKit
import Kingfisher

public protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func updateAvatar()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    
    private let profileService = ProfileService.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    
    func viewDidLoad() {
        updateNotification()
        updateProfileDetails()
        updateAvatar()
    }
    
    func updateNotification() {
        NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
    }
    
    private func updateProfileDetails() {
        guard let token = tokenStorage.getToken() else { return }
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                self.view?.displayProfileDetails(name: profile.name, username: profile.loginName, description: profile.bio ?? "")
            case .failure(let error):
                print("Error fetching token: \(error)")
            }
        }
    }
    
    func updateAvatar() {
        guard let profileImageURL = ProfileImageService.shared.avatarURL else { return }
        self.view?.displayAvatar(imageURL: profileImageURL)
    }
}
