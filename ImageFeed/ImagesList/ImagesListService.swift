//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Bakgeldi Alkhabay on 20.07.2024.
//

import Foundation

final class ImagesListService {
    static let shared = ImagesListService()
    
    private init() {}
    
    static let updatedPhotoList = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private (set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private let tokenStorage = OAuth2TokenStorage.shared
    private let stringToDateFormatter = ISO8601DateFormatter()
    
    private let photosPerPage = 10
    
    private enum ImagesListServiceErrors: Error {
        case invalidRequest
    }
    
    func fetchPhotosNextPage(_ username: String, completion: @escaping () -> Void) {
        assert(Thread.isMainThread)
        
        task?.cancel()
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let request = makeRequest(nextPage) else {
            print("[ImagesListService: fetchPhotosNextPage]: Error while creating request")
            return
        }
        
        let urlSession = URLSession.shared
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let list):
                let newPhotos: [Photo] = []
                for photo in list {
                    let newPhoto = Photo(
                        id: photo.id,
                        size: CGSize(width: photo.width, height: photo.height),
                        createdAt: self.stringToDateFormatter.date(from: photo.createdAt ?? ""),
                        welcomeDescription: photo.description,
                        thumbImageURL: photo.urls.thumb,
                        largeImageURL: photo.urls.full,
                        isLiked: photo.likedByUser)
                    
                    DispatchQueue.main.async {
                        self.photos.append(newPhoto)
                    }
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.updatedPhotoList,
                        object: self,
                        userInfo: ["New photo ID": newPhoto.id]
                    )
                }
                
                self.lastLoadedPage = nextPage
                print("[ImagesListService: fetchPhotosNextPage]: Images successfully loaded")
                
            case .failure(let error):
                print("[ImagesListService: fetchPhotosNextPage]: Network error - \(error)")
            }
            
            self.task = nil
        }
        
        self.task = task
        task.resume()
    }
    
    func makeRequest(_ page: Int) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://api.unsplash.com/photos") else {
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(self.photosPerPage)")
        ]
        
        guard let url = urlComponents.url else { return nil}
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return request
    }
}
