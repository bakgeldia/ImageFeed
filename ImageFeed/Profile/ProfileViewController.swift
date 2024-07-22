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
    
    // MARK: - Private Properties
    private var labelName: UILabel?
    private var labelUsername: UILabel?
    private var labelDescription: UILabel?
    private var profileImageView: UIImageView?
    
    private var imageView = UIImageView()
    private var name = UILabel()
    private var username = UILabel()
    private var profileDescription = UILabel()
    private var button = UIButton()
    
    private var profileService = ProfileService.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUIElements()
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        
        updateProfileDetails()
        updateAvatar()
    }
    
    // MARK: - IBAction
    @IBAction private func didTapLogoutButton() {}
    
    // MARK: - Private Methods
    @objc
    private func didTapButton() {
        let alert = UIAlertController(title: "Выход из аккаунта",
                                      message: "Вы уверены, что хотите выйти?",
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "Выйти", style: .destructive) { _ in
            ProfileLogoutService.shared.logout()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func setUpUIElements() {
        view.backgroundColor = UIColor(named: "ypBlack")
        
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        
        name.textColor = .white
        name.font = UIFont.systemFont(ofSize: 23)
        name.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(name)
        name.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        name.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        name.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        self.labelName = name
        
        username.textColor = .gray
        username.font = UIFont.systemFont(ofSize: 13)
        username.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(username)
        username.leadingAnchor.constraint(equalTo: name.leadingAnchor).isActive = true
        username.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 8).isActive = true
        username.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        self.labelUsername = username
        
        profileDescription.numberOfLines = 0
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
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        let cache = ImageCache.default
        cache.clearMemoryCache()
        cache.clearDiskCache()
        
        let processor = RoundCornerImageProcessor(cornerRadius: 50)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: url,
                              placeholder: UIImage(named: "placeholder"),
                              options: [ .processor(processor)]
        )
        self.profileImageView = imageView
    }
    
    private func updateProfileDetails() {
        guard let token = tokenStorage.getToken() else { return }
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                name.text = profile.name
                username.text = profile.loginName
                profileDescription.text = profile.bio

            case .failure(let error):
                print("Error fetching token: \(error)")
            }
        }
    }
    
}
