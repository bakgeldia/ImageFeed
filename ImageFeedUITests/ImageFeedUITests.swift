//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Bakgeldi Alkhabay on 28.07.2024.
//

@testable import ImageFeed
import XCTest
import WebKit

final class ImageFeedUITests: XCTestCase {
    
    private let app = XCUIApplication() // переменная приложения
    
    override func setUpWithError() throws {
        continueAfterFailure = false // настройка выполнения тестов, которая прекратит выполнения тестов, если в тесте что-то пошло не так
        
        app.launch() // запускаем приложение перед каждым тестом
    }
    
    func testAuth() throws {
        sleep(2)
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 10))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 10))
        
        loginTextField.tap()
        loginTextField.typeText("<Login>")
        sleep(2)
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 10))
        
        passwordTextField.tap()
        passwordTextField.typeText("<Password>")
        sleep(2)
        webView.swipeUp()
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 10))
    }
    
    func testFeed() throws {
        XCTAssertTrue(app.tables.element.waitForExistence(timeout: 10), "Feed screen did not load in time")
        
        // Сделать жест «смахивания» вверх по экрану для его скролла
        app.tables.element.swipeUp()
        sleep(2)
        app.tables.element.swipeDown()
        sleep(2)
        // Поставить лайк в ячейке верхней картинки
        let firstCell = app.tables.cells.element(boundBy: 0)
        
        //let firstCell = app.tables.children(matching: .cell).element(boundBy: 0)
        let likeButton = firstCell.buttons["like_button"]
        likeButton.tap()
        
        sleep(3)
        
        // Отменить лайк в ячейке верхней картинки
        likeButton.tap()
        
        sleep(3)
        
        // Нажать на верхнюю ячейку
        firstCell.tap()
        
        // Подождать, пока картинка открывается на весь экран
        let imageView = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(imageView.waitForExistence(timeout: 5), "Image did not load in time")
        sleep(3)
        
        // Увеличить картинку
        imageView.pinch(withScale: 3, velocity: 1)
        sleep(1)
        // Уменьшить картинку
        imageView.pinch(withScale: 0.5, velocity: -1)
        sleep(1)
        
        // Вернуться на экран ленты
        let navBackButtonWhiteButton = app.buttons["nav_button_back"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        sleep(2)
        
        XCTAssertTrue(app.staticTexts["Bakgeldi Alkhabay"].exists)
        XCTAssertTrue(app.staticTexts["@baaaka"].exists)
        
        app.buttons["logout_button"].tap()
        sleep(2)
        
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Yes"].tap()
    }
}
