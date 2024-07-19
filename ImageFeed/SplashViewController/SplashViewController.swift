//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Bakgeldi Alkhabay on 09.07.2024.
//

import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Public Properties
    var splashImage: UIImageView?
    
    // MARK: - Private Properties
    private let storage = OAuth2TokenStorage.shared
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let oAuthService = OAuth2Service.shared
    private var profileService = ProfileService.shared
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupView()
        setupAuthorization()
    }
    
    // MARK: - Private Functions
    
    private func setupView() {
        view.backgroundColor = UIColor(named: "ypBlack")
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "splash_screen_logo")
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 75),
            imageView.heightAnchor.constraint(equalToConstant: 77)
        ])
        
        self.splashImage = imageView
    }
    
    private func setupAuthorization() {
        if let token = storage.getToken() {
            fetchProfile(token)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
                fatalError("AuthViewController is not found")
            }
            authViewController.delegate = self
            authViewController.modalPresentationStyle = .fullScreen
            
            present(authViewController, animated: true, completion: nil)
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        window.rootViewController = tabBarController
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        
        guard let token = storage.getToken() else { return }
        fetchProfile(token)
    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case .success(let result):
                ProfileImageService.shared.fetchProfileImageURL(username: result.username) { _ in }
                self.switchToTabBarController()
            case .failure(let error):
                print("Error fetching profile: \(error)")
                break
            }
        }
    }
}
