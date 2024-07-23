//
//  ViewController.swift
//  ImageFeed
//
//  Created by Bakgeldi Alkhabay on 07.05.2024.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Private Properties
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var photos: [Photo] = []
    private var imagesListService = ImagesListService.shared
    private var imagesListServiceObserver: NSObjectProtocol?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        photos = imagesListService.photos
        
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) {[weak self] _ in
            self?.updateTableViewAnimated()
        }
        
        imagesListService.fetchPhotosNextPage("") { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            if let viewController = segue.destination as? SingleImageViewController,
               let indexPath = sender as? IndexPath {
                viewController.largeImageURL = photos[indexPath.row].largeImageURL
            } else {
                super.prepare(for: segue, sender: sender)
            }
        }
    }
    
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                var indexPaths: [IndexPath] = []
                for i in oldCount..<newCount {
                    indexPaths.append(IndexPath(row: i, section: 0))
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let imageListCell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath)

        return imageListCell
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        guard let url = URL(string: photo.thumbImageURL) else { return }
        
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(
            with: url,
            placeholder: UIImage(named: "Stub")
        ) { [weak self] _ in
            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        cell.dateLabel.text = dateFormatter.string(from: photo.createdAt ?? Date())

        let likeImage = UIImage(named: photo.isLiked ? "like_button_on" : "like_button_off")
        cell.likeButton.setImage(likeImage, for: .normal)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage("") {}
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard self.photos.count > 0 else { return 0 }
        
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: "\(photo.id)", isLike: photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let like):
                setIsLiked(cell, like)
                
                UIBlockingProgressHUD.dismiss()
                print("[ImagesListViewController: imageListCellDidTapLike]: Like for image changed. Image id: \(photo.id)")
            case .failure(let error):
                print("[ImagesListViewController: imageListCellDidTapLike]: Error like image.\(error)")
                UIBlockingProgressHUD.dismiss()
                let alertController = UIAlertController(
                    title: "Что-то пошло не так(",
                    message: "Не удалось поставить/убрать лайк",
                    preferredStyle: .alert
                )
                
                let okAction = UIAlertAction(
                    title: "Ok",
                    style: .default,
                    handler: nil
                )
                
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func setIsLiked(_ cell: ImagesListCell, _ like: Bool) {
        guard let image = UIImage(named: like ? "like_button_on" : "like_button_off") else {
            return
        }
        cell.likeButton.setImage(image, for: .normal)
    }
}

