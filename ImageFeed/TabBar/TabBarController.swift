//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Bakgeldi Alkhabay on 18.07.2024.
//

import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        guard let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController
        else { return }
        
        let imagesListPresenter = ImagesListPresenter()
        imagesListViewController.configure(imagesListPresenter)
    
        
        imagesListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_editorial_active"),
            selectedImage: nil
        )
        
        let profileViewPresenter = ProfilePresenter()
        let profileViewController = ProfileViewController()
        profileViewController.configure(profileViewPresenter)
        
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
