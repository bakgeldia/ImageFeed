//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Bakgeldi Alkhabay on 16.07.2024.
//

import UIKit

final class ProfileService {
    static let shared = ProfileService()
    
    private init() {}
    
    private(set) var profile: Profile?
    
    private enum AuthServiceError: Error {
        case invalidRequest
    }
    
    private enum NetworkError: Error {
        case invalidJSON
    }
    
    private var task: URLSessionTask?
    private let tokenStorage = OAuth2TokenStorage.shared
    
    func makeRequest(token: String) -> URLRequest?  {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard tokenStorage.getToken() == token else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        
        guard let request = makeRequest(token: token) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let urlSession = URLSession.shared
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                do {
                    self.profile = Profile(username: data.username, name: data.name, loginName: "@\(data.username)", bio: data.bio ?? "No description")
                    completion(.success(self.profile ?? Profile(username: "", name: "", loginName: "", bio: "")))
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

struct ProfileResult: Codable {
    let username: String
    let name: String
    let bio: String?
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}
