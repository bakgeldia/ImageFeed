//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Bakgeldi Alkhabay on 28.07.2024.
//

import UIKit

public protocol ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    func viewDidLoad()
    func fetchNextPage()
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    private var imagesListService = ImagesListService.shared
    
    func viewDidLoad() {
        setNotification()
        fetchNextPage()
    }
    
    func setNotification() {
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) {[weak self] _ in
            self?.view?.updateTableViewAnimated()
        }
    }
    
    func fetchNextPage() {
        imagesListService.fetchPhotosNextPage("") { [weak self] in
            self?.view?.updateTableView()
        }
    }
}
