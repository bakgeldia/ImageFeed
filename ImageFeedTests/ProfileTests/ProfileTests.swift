//
//  ProfileTests.swift
//  ImageFeedTests
//
//  Created by Bakgeldi Alkhabay on 28.07.2024.
//

import XCTest
import Kingfisher
@testable import ImageFeed

final class ProfileTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testUpdateAvatar() {
        // Arrange
        let viewControllerSpy = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        presenter.view = viewControllerSpy
        
        let expectedImageURL = "https://example.com/avatar.jpg"
        ProfileImageService.shared.avatarURL = expectedImageURL
        
        // Act
        presenter.updateAvatar()
        
        // Assert
        XCTAssertTrue(viewControllerSpy.displayAvatarCalled)
        XCTAssertEqual(viewControllerSpy.displayAvatarImageURL, expectedImageURL)
    }
    
    func testViewDidLoadCallsPresenterViewDidLoad() {
        // Given
        let presenterSpy = ProfilePresenterSpy()
        let viewController = ProfileViewController()
        viewController.presenter = presenterSpy
        
        // When
        viewController.viewDidLoad()
        
        // Then
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }
    
    func testDisplayProfileDetails() {
        // Given
        let viewController = ProfileViewController()
        viewController.loadViewIfNeeded()
        
        let expectedName = "John Doe"
        let expectedUsername = "johndoe"
        let expectedDescription = "Lorem ipsum dolor sit amet"
        
        // When
        viewController.displayProfileDetails(name: expectedName, username: expectedUsername, description: expectedDescription)
        
        // Then
        XCTAssertEqual(viewController.name.text, expectedName)
        XCTAssertEqual(viewController.username.text, expectedUsername)
        XCTAssertEqual(viewController.profileDescription.text, expectedDescription)
    }
    
    func testDisplayAvatar() {
        // Given
        let viewController = ProfileViewController()
        viewController.loadViewIfNeeded()
        
        let expectedImageURL = "https://example.com/avatar.jpg"
        guard let url = URL(string: expectedImageURL) else {
            XCTFail("URL is not valid")
            return
        }
        
        // When
        viewController.displayAvatar(imageURL: expectedImageURL)
        
        // Then
        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
            case .success(let value):
                XCTAssertEqual(value.source.url, url)
            case .failure:
                XCTFail("Image download failed")
            }
        }
    }
}
