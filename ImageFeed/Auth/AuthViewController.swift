//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Bakgeldi Alkhabay on 07.07.2024.
//

import UIKit

final class AuthViewController: UIViewController {
    // MARK: - IBOutlet
    
    // MARK: - Private Properties
    private let ShowWebViewSegueIdentifier = "ShowWebView"
    private let OAuthService = OAuth2Service()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else { fatalError("Failed to prepare for \(ShowWebViewSegueIdentifier)") }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Private Methods

    
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        OAuthService.fetchOAuthToken(code: code) { [weak self] result in
            switch result {
            case .success(let token):
                print("Access token: \(token)" )
                self?.dismiss(animated: true)
            case .failure(let error):
                print("Error fetching token: \(error)")
                let alert = UIAlertController(title: "Error", message: "Failed to fetch token: \(error.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}
