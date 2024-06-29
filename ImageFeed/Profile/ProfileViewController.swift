//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Bakgeldi Alkhabay on 07.06.2024.
//

import UIKit

final class ProfileViewController: UIViewController {
    @IBOutlet private var avatarImageView: UIImageView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var loginNameLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var logoutButton: UIButton!
    
    
    var labelName: UILabel?
    var labelUsername: UILabel?
    var labelDescription: UILabel?
    var profileImageView: UIImageView?
    
    override func viewDidLoad() {
        let profileImage = UIImage(named: "ProfilePhoto")
        let imageView = UIImageView(image: profileImage)
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        self.profileImageView = imageView
        
        let name = UILabel()
        name.text = "Екатерина Новикова"
        name.textColor = .white
        name.font = UIFont.systemFont(ofSize: 23)
        name.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(name)
        name.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        name.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        self.labelName = name
        
        let username = UILabel()
        username.text = "@ekaterina_nov"
        username.textColor = .gray
        username.font = UIFont.systemFont(ofSize: 13)
        username.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(username)
        username.leadingAnchor.constraint(equalTo: name.leadingAnchor).isActive = true
        username.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 8).isActive = true
        self.labelUsername = username
        
        let description = UILabel()
        description.text = "Hello, World!"
        description.textColor = .white
        description.font = UIFont.systemFont(ofSize: 13)
        description.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(description)
        description.leadingAnchor.constraint(equalTo: name.leadingAnchor).isActive = true
        description.topAnchor.constraint(equalTo: username.bottomAnchor, constant: 8).isActive = true
        self.labelDescription = description
        
        let button = UIButton.systemButton(
            with: UIImage(named: "logout")!,
            target: self,
            action: #selector(Self.didTapButton)
        )
        button.tintColor = .red
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.widthAnchor.constraint(equalToConstant: 48).isActive = true
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
        button.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
    }
    
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
    
    @IBAction private func didTapLogoutButton() {
        
    }
}
