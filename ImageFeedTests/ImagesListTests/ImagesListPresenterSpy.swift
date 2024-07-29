//
//  ImagesListPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Bakgeldi Alkhabay on 28.07.2024.
//

import Foundation
import ImageFeed

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    
    private(set) var viewDidLoadCalled = false
    private(set) var fetchNextPageCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func fetchNextPage() {
        fetchNextPageCalled = true
    }
}
