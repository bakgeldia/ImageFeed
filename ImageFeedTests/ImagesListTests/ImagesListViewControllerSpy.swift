//
//  ImagesListViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Bakgeldi Alkhabay on 28.07.2024.
//

import Foundation
import ImageFeed
import XCTest

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol?
    
    private(set) var updateTableViewCalled = false
    private(set) var updateTableViewAnimatedCalled = false
    private(set) var displayErrorCalled = false
    
    var updateTableViewExpectation: XCTestExpectation?
    
    func updateTableView() {
        updateTableViewCalled = true
    }
    
    func updateTableViewAnimated() {
        updateTableViewAnimatedCalled = true
    }
    
    func displayError() {
        displayErrorCalled = true
    }
}
