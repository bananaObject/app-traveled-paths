//
//  LoginViewController.swift
//  googleMap
//
//  Created by Ke4a on 13.12.2022.
//

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

    private var presenter: LoginViewOutput?

    // MARK: - Initialization

    init(presenter: LoginViewOutput) {
        super.init(nibName: nil, bundle: nil)
        self.presenter = presenter
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
}

// MARK: - LoginViewInput

extension LoginViewController: LoginViewInput {
    func showAllert(_ tittle: String, _ text: String) {
        loginView.showAllert(tittle, text)
    }
}

// MARK: - LoginViewOutput

extension LoginViewController: LoginViewOutput {
    func viewRequestedRegistration(_ login: String, _ pass: String) {
        presenter?.viewRequestedRegistration(login, pass)
    }

    func viewRequestedLogin(_ login: String, _ pass: String) {
        presenter?.viewRequestedLogin(login, pass)
    }
}
