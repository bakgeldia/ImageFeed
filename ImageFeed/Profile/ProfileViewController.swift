//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Bakgeldi Alkhabay on 07.06.2024.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet private var avatarImageView: UIImageView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var loginNameLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var logoutButton: UIButton!
    
    // MARK: - Public Properties
    var labelName: UILabel?
    var labelUsername: UILabel?
    var labelDescription: UILabel?
    var profileImageView: UIImageView?
    
    var imageView = UIImageView()
    var name = UILabel()
    var username = UILabel()
    var profileDescription = UILabel()
    var button = UIButton()
    
    private var profileService = ProfileService.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        
        updateAvatar()
        
        guard let profile = profileService.profile else { return }
        updateProfileDetails(profile: profile)
    }
    
    // MARK: - IBAction
    @IBAction private func didTapLogoutButton() {
        
    }
    
    // MARK: - Private Methods
    @objc
    private func didTapButton() {
        labelName?.removeFromSuperview()
        labelName = nil
        
        labelUsername?.removeFromSuperview()
        labelUsername = nil
        
        labelDescription?.removeFromSuperview()
        labelDescription = nil
        
        profileImageView?.image = UIImage(systemName: "person.crop.circle.fill")
        profileImageView?.tintColor = .gray
        
    }
    
    private func updateAvatar() {                                   // 8
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        self.profileImageView = imageView
        
        let cache = ImageCache.default
        cache.clearMemoryCache()
        cache.clearDiskCache()
        
        let processor = RoundCornerImageProcessor(cornerRadius: 50)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: url,
                              placeholder: UIImage(named: "placeholder.jpeg"),
                              options: [ .processor(processor)]
                              ){ result in
                                  switch result {
                                  case .success(let value):
                                      print(value.image)
                                      print(value.cacheType)
                                      print(value.source)
                                  case .failure(let error):
                                      print(error)
                                  }
                              }
        
    }
    
    private func updateProfileDetails(profile: Profile) {
//        guard let token = tokenStorage.token else { return }
        guard let token = tokenStorage.getToken() else { return }
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                name.text = profile.name
                name.textColor = .white
                name.font = UIFont.systemFont(ofSize: 23)
                name.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(name)
                name.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
                name.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
                name.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
                self.labelName = name
                
                username.text = profile.loginName
                username.textColor = .gray
                username.font = UIFont.systemFont(ofSize: 13)
                username.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(username)
                username.leadingAnchor.constraint(equalTo: name.leadingAnchor).isActive = true
                username.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 8).isActive = true
                username.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
                self.labelUsername = username
                
                profileDescription.numberOfLines = 0
                profileDescription.text = profile.bio
                profileDescription.textColor = .white
                profileDescription.font = UIFont.systemFont(ofSize: 13)
                profileDescription.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(profileDescription)
                profileDescription.leadingAnchor.constraint(equalTo: name.leadingAnchor).isActive = true
                profileDescription.topAnchor.constraint(equalTo: username.bottomAnchor, constant: 8).isActive = true
                profileDescription.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
                self.labelDescription = profileDescription
                
                button = UIButton.systemButton(
                    with: UIImage(named: "Logout") ?? UIImage(),
                    target: self,
                    action: #selector(Self.didTapButton)
                )
                button.tintColor = UIColor(red: 245.0/255.0, green: 107.0/255.0, blue: 108.0/255.0, alpha: 1)
                button.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(button)
                button.widthAnchor.constraint(equalToConstant: 48).isActive = true
                button.heightAnchor.constraint(equalToConstant: 48).isActive = true
                button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
                button.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
            
            case .failure(let error):
                print("Error fetching token: \(error)")
            }
        }
    }
    
}
