//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Bakgeldi Alkhabay on 09.07.2024.
//

import UIKit

final class OAuth2Service {
    private enum NetworkError: Error {
        case invalidJSON
    }
    
    private enum AuthServiceError: Error {
        case invalidRequest
    }
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    private let tokenStorage = OAuth2TokenStorage.shared
    
    weak var delegate: AuthViewControllerDelegate?
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            return nil
        }
        
        guard let url = URL(string: "/oauth/token"
                            + "?client_id=\(Constants.accessKey)"
                            + "&&client_secret=\(Constants.secretKey)"
                            + "&&redirect_uri=\(Constants.redirectURI)"
                            + "&&code=\(code)"
                            + "&&grant_type=authorization_code",
                            relativeTo: baseURL) 
        else {
            assertionFailure("Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let urlSession = URLSession.shared
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                do {
                    self.tokenStorage.saveToken(data.access_token)
                    completion(.success("\(data.access_token)"))
                }
            case .failure(let error):
                print("Network error occurred: \(error)")
                completion(.failure(error))
            }
            
            self.task = nil
            self.lastCode = nil
        }
        self.task = task
        task.resume()
    }
}
