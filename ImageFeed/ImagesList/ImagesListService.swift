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
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private (set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private var likeTask: URLSessionTask?
    private let tokenStorage = OAuth2TokenStorage.shared
    private let stringToDateFormatter = ISO8601DateFormatter()
    
    private let photosPerPage = 10
    private let baseURL = "https://api.unsplash.com"
    
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
                var newPhotos: [Photo] = []
                for photo in list {
                    let newPhoto = Photo(
                        id: photo.id,
                        size: CGSize(width: photo.width, height: photo.height),
                        createdAt: self.stringToDateFormatter.date(from: photo.createdAt ?? ""),
                        welcomeDescription: photo.description,
                        thumbImageURL: photo.urls.thumb,
                        largeImageURL: photo.urls.full,
                        isLiked: photo.likedByUser)
                    
                    newPhotos.append(newPhoto)
                }
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self,
                        userInfo: ["New photo IDs": newPhotos.map { $0.id }]
                    )
                    print("[ImagesListService: fetchPhotosNextPage]: Images successfully loaded")
                }
                
            case .failure(let error):
                print("[ImagesListService: fetchPhotosNextPage]: Network error - \(error)")
            }
            
            self.task = nil
        }
        
        self.task = task
        task.resume()
    }
    
    func makeRequest(_ page: Int) -> URLRequest? {
        guard let url = URL(string: baseURL + "/photos?page=\(page)&per_page=\(self.photosPerPage)"),
              let token = tokenStorage.getToken() else { return nil }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        return request
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        likeTask?.cancel()
        
        guard let request = makeLikePhotoRequest(url: "\(baseURL)/photos/\(photoId)/like", httpMethod: isLike ? "DELETE" : "POST")
        else {
            print("[ImagesListService: changeLike]: Error while creating request")
            return
        }
        
        let urlSession = URLSession.shared
        let likeTask = urlSession.objectTask(for: request) { [weak self] (result: Result<LikedPhotoResult, Error>) in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.likeTask = nil
                var liked = false
                switch result {
                case .success(_):
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        self.photos[index].isLiked = !self.photos[index].isLiked
                        liked =  self.photos[index].isLiked
                    }
//                        let photo = self.photos[index]
//                        let newPhoto = Photo(
//                                    id: photo.id,
//                                    size: photo.size,
//                                    createdAt: photo.createdAt,
//                                    welcomeDescription: photo.welcomeDescription,
//                                    thumbImageURL: photo.thumbImageURL,
//                                    largeImageURL: photo.largeImageURL,
//                                    isLiked: !photo.isLiked
//                                )
//                        self.photos[index] = newPhoto
//                    }
                    
                    completion(.success(liked))
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        self.likeTask = likeTask
        likeTask.resume()
    }
    
    func makeLikePhotoRequest(url: String, httpMethod: String) -> URLRequest? {
        
        guard let url = URL(string: url) else { return nil }
        guard let token = tokenStorage.getToken() else { return nil }
        print("Using token: \(token)")
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = httpMethod
        return request
    }
}
