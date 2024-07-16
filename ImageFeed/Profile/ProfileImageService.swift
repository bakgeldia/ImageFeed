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
    private let tokenStorage = OAuth2TokenStorage()
    private var task: URLSessionTask?
    private var lastUsername: String?
    
    private init() {}
    
    private (set) var avatarURL: String?
    
    private enum AuthServiceError: Error {
        case invalidRequest
    }
    
    private enum NetworkError: Error {
        case invalidJSON
    }

    
    func makeRequest(username: String) -> URLRequest?  {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(tokenStorage.token ?? "")", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        return request
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastUsername != username else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastUsername = username

        
        guard let request = makeRequest(username: username) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let decoder = JSONDecoder()
        
        let task = URLSession.shared.data(for: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                do {
                    let response = try decoder.decode(UserResult.self, from: data)
                    self.avatarURL = response.profile_image.small
                    completion(.success(self.avatarURL ?? ""))
                    NotificationCenter.default
                        .post(
                            name: ProfileImageService.didChangeNotification,
                            object: self,
                            userInfo: ["URL": response.profile_image.small])
                } catch {
                    print("Error decoding profile image: \(error)")
                    completion(.failure(NetworkError.invalidJSON))
                }
            case .failure(let error):
                print("Network error occurred: \(error)")
                completion(.failure(error))
            }
            
            self.task = nil
        }
        
        self.task = task
        task.resume()
    }
    
}

struct UserResult: Codable {
    struct ProfileImage: Codable {
        let small: String
    }
    let profile_image: ProfileImage
}
