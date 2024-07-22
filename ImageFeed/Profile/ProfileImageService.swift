//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Bakgeldi Alkhabay on 16.07.2024.
//

import UIKit

final class ProfileImageService {
    
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private let tokenStorage = OAuth2TokenStorage.shared
    private var task: URLSessionTask?
    
    private init() {}
    
    private (set) var avatarURL: String?
    
    private enum ProfileImageServiceErrors: Error {
        case invalidRequest
    }
    
    private func makeRequest(username: String) -> URLRequest?  {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(tokenStorage.getToken() ?? "")", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        return request
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        task?.cancel()
        
        guard let request = makeRequest(username: username) else {
            print("[ProfileImageService: fetchProfileImageURL]: Error while creating request")
            completion(.failure(ProfileImageServiceErrors.invalidRequest))
            return
        }
        
        let urlSession = URLSession.shared
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                do {
                    self.avatarURL = data.profile_image.small
                    completion(.success(self.avatarURL ?? ""))
                    NotificationCenter.default
                        .post(
                            name: ProfileImageService.didChangeNotification,
                            object: self,
                            userInfo: ["URL": data.profile_image.small])
                }
            case .failure(let error):
                print("[ProfileImageService: fetchProfileImageURL]: Network error - \(error)")
                completion(.failure(error))
            }
            
            self.task = nil
        }
        
        self.task = task
        task.resume()
    }
    
    func cleanAvatarURL() {
        avatarURL = nil
    }
    
}
