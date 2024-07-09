//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Bakgeldi Alkhabay on 09.07.2024.
//

import UIKit

class OAuth2Service {
    private enum NetworkError: Error {
        case invalidURL
        case invalidJSON
    }
    
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
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let decoder = JSONDecoder()
        
        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    let tokenStorage = OAuth2TokenStorage()
                    tokenStorage.token = response.access_token
                    completion(.success("\(response.access_token)"))
                } catch {
                    print("Error decoding OAuthTokenResponseBody: \(error)")
                    completion(.failure(NetworkError.invalidJSON))
                }
            case .failure(let error):
                print("Network error occurred: \(error)")
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
