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
    
    //private(set) var profile: Profile?
    
    private enum ProfileServiceErrors: Error {
        case invalidRequest
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
            print("[ProfileService: fetchProfile]: Invalid request")
            completion(.failure(ProfileServiceErrors.invalidRequest))
            return
        }
        
        task?.cancel()
        
        guard let request = makeRequest(token: token) else {
            print("[ProfileService: fetchProfile]: Invalid request")
            completion(.failure(ProfileServiceErrors.invalidRequest))
            return
        }
        
        let urlSession = URLSession.shared
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                do {
                    let profile = Profile(
                        username: data.username,
                        name: data.name,
                        loginName: "@\(data.username)",
                        bio: data.bio ?? "No description"
                    )
                    
                    completion(.success(profile))
                }
            case .failure(let error):
                print("[ProfileService: fetchProfile]: Network error - \(error)")
                completion(.failure(error))
            }
            
            self.task = nil
        }
        
        self.task = task
        task.resume()
    }
}
