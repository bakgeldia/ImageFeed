//
//  UITableViewSpy.swift
//  ImageFeedTests
//
//  Created by Bakgeldi Alkhabay on 28.07.2024.
//

import UIKit

class UITableViewSpy: UITableView {
    private(set) var reloadDataCalled = false
    
    override func reloadData() {
        super.reloadData()
        reloadDataCalled = true
    }
}
