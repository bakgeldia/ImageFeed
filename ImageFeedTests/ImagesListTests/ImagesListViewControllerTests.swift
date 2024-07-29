//
//  ImagesListTests.swift
//  ImageFeedTests
//
//  Created by Bakgeldi Alkhabay on 28.07.2024.
//

import XCTest
@testable import ImageFeed

final class ImagesListViewControllerTests: XCTestCase {
    
    var viewController: ImagesListViewController!
    var presenterSpy: ImagesListPresenterSpy!
    var tableViewSpy: UITableViewSpy!
    
    override func setUp() {
        super.setUp()
        viewController = ImagesListViewController()
        presenterSpy = ImagesListPresenterSpy()
        viewController.presenter = presenterSpy
        tableViewSpy = UITableViewSpy()
        viewController.setTableView(tableViewSpy)
    }
    
    override func tearDown() {
        viewController = nil
        presenterSpy = nil
        tableViewSpy = nil
        super.tearDown()
    }
    
    func testViewDidLoad_CallsPresenterViewDidLoad() {
        // Arrange
        // Done in setUp
        
        // Act
        viewController.viewDidLoad()
        
        // Assert
        XCTAssertTrue(presenterSpy.viewDidLoadCalled, "viewDidLoad() should call presenter's viewDidLoad()")
    }
    
    func testUpdateTableView_CallsReloadData() {
        // Arrange
        // Done in setUp
        
        // Act
        viewController.updateTableView()
        
        // Assert
        XCTAssertTrue(tableViewSpy.reloadDataCalled, "updateTableView() should call tableView.reloadData()")
    }
    
    func testDisplayError_ShowsAlert() {
        // Arrange
        let window = UIWindow()
        window.addSubview(viewController.view)
        let expectation = self.expectation(description: "Alert displayed")
        
        // Act
        viewController.displayError()
        
        // Assert
        DispatchQueue.main.async {
            if let presentedViewController = self.viewController.presentedViewController as? UIAlertController {
                XCTAssertEqual(presentedViewController.title, "Что-то пошло не так(", "Alert title should be 'Что-то пошло не так('")
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
}
