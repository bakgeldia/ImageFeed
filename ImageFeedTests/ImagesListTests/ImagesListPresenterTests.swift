//
//  ImagesListPresenterTests.swift
//  ImageFeedTests
//
//  Created by Bakgeldi Alkhabay on 28.07.2024.
//

import XCTest
@testable import ImageFeed

final class ImagesListPresenterTests: XCTestCase {
    
    var presenter: ImagesListPresenter!
    var viewControllerSpy: ImagesListViewControllerSpy!

    override func setUp() {
        super.setUp()
        presenter = ImagesListPresenter()
        viewControllerSpy = ImagesListViewControllerSpy()
        presenter.view = viewControllerSpy
    }

    override func tearDown() {
        presenter = nil
        viewControllerSpy = nil
        super.tearDown()
    }

    func testViewDidLoad_SetsNotification() {
        // Arrange
        let notificationName = ImagesListService.didChangeNotification

        // Act
        presenter.viewDidLoad()
        NotificationCenter.default.post(name: notificationName, object: nil)

        // Assert
        XCTAssertTrue(viewControllerSpy.updateTableViewAnimatedCalled, "viewDidLoad() should call view.updateTableViewAnimated() when notification is posted")
    }
}
