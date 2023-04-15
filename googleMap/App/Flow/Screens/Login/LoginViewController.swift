//
//  LoginViewController.swift
//  googleMap
//
//  Created by Ke4a on 13.12.2022.
//

import GoogleMaps
import UIKit

final class LoginViewController: UIViewController {
    // MARK: - Visual Components

    private var loginView: LoginView {
        guard let view = view as? LoginView else {
            let correctView = LoginView(self)
            self.view = correctView
            return correctView
        }

        return view
    }

    // MARK: - Private Properties

    private var presenter: LoginViewOutput

    // MARK: - Initialization

    init(presenter: LoginViewOutput) {
        self.presenter = presenter

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        super.loadView()

        let view = LoginView(self)
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loginView.setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewCheckApiKey()
    }
}

// MARK: - LoginViewInput

extension LoginViewController: LoginViewInput {
    func showSetApiKeyAller() {
        let alert = UIAlertController(title: "Google map api key",
                                      message: "Это тестовое приложение, введите ключ API от google maps",
                                      preferredStyle: .alert)

        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            guard let filed = alert.textFields?.first as? UITextField, let text = filed.text, text.count == 39 else {
                self.present(alert, animated: true)
                return
            }

            UserDefaults.standard.set(text, forKey: "ApiKey")
            GMSServices.provideAPIKey(text)
        }

        alert.addTextField { (textField) in
            textField.placeholder = "Api key"
        }

        alert.addAction(confirmAction)
        present(alert, animated: true)
    }

    func showAllert(_ tittle: String, _ text: String) {
        let allert = UIAlertController(title: tittle, message: text, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .default)
        allert.addAction(cancelAction)
        present(allert, animated: true)
    }
}

// MARK: - LoginViewOutput

extension LoginViewController: LoginViewOutput {
    func viewCheckApiKey() {
        presenter.viewCheckApiKey()
    }

    func viewRequestedRegistration(_ login: String, _ pass: String) {
        presenter.viewRequestedRegistration(login, pass)
    }

    func viewRequestedLogin(_ login: String, _ pass: String) {
        presenter.viewRequestedLogin(login, pass)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        loginView.nextResponder(current: textField)
    }
}
