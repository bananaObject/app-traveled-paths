//
//  LoginView.swift
//  googleMap
//
//  Created by Ke4a on 13.12.2022.
//

import RxCocoa
import RxSwift
import UIKit

final class LoginView: UIView {
    // MARK: - Visual Components

    private lazy var registerSwitch: UISwitch =  {
        let control = UISwitch()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.onTintColor = .gray
        control.clipsToBounds = true
        control.transform = CGAffineTransformMakeScale(0.75, 0.75)
        return control
    }()

    private lazy var switchLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Registration"
        label.textColor = .gray
        return label
    }()

    private lazy var loginField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = "Username"
        return field
    }()

    private lazy var passField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.isSecureTextEntry = true
        field.placeholder = "Password"
        return field
    }()

    private lazy var submitButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        button.layer.backgroundColor = UIColor.darkGray.cgColor
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.gray, for: .disabled)
        button.backgroundColor = .lightGray
        button.isEnabled = false
        return button
    }()

    private lazy var disposeBag = DisposeBag()

    // MARK: - Public Properties

    weak var controller: (UIViewController & LoginViewOutput)?

    // MARK: - Initialization

    init(_ controller: UIViewController & LoginViewOutput) {
        super.init(frame: .zero)
        self.controller = controller
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setting UI Methods

    /// Settings ui components.
    func setupUI() {
        backgroundColor = .white

        setupField()
        configureBindingsFields()

        addSubview(registerSwitch)
        NSLayoutConstraint.activate([
            registerSwitch.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            registerSwitch.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -8)
        ])

        addSubview(switchLabel)
        NSLayoutConstraint.activate([
            switchLabel.trailingAnchor.constraint(equalTo: registerSwitch.leadingAnchor),
            switchLabel.centerYAnchor.constraint(equalTo: registerSwitch.centerYAnchor)
        ])

        addSubview(loginField)
        NSLayoutConstraint.activate([
            loginField.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 8),
            loginField.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -8),
            loginField.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.05),
            loginField.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor,
                                                constant: UIScreen.main.bounds.height * -0.07)
        ])

        addSubview(passField)
        NSLayoutConstraint.activate([
            passField.topAnchor.constraint(equalTo: loginField.bottomAnchor, constant: 8),
            passField.leadingAnchor.constraint(equalTo: loginField.leadingAnchor),
            passField.trailingAnchor.constraint(equalTo: loginField.trailingAnchor),
            passField.heightAnchor.constraint(equalTo: loginField.heightAnchor)
        ])

        addSubview(submitButton)
        NSLayoutConstraint.activate([
            submitButton.topAnchor.constraint(equalTo: passField.bottomAnchor, constant: 16),
            submitButton.leadingAnchor.constraint(equalTo: passField.leadingAnchor),
            submitButton.trailingAnchor.constraint(equalTo: passField.trailingAnchor),
            submitButton.heightAnchor.constraint(equalTo: passField.heightAnchor, multiplier: 1.5)
        ])

        submitButton.addTarget(self, action: #selector(submitButtonAction), for: .touchUpInside)
        registerSwitch.addTarget(self, action: #selector(registerSwitchAction), for: .valueChanged)
    }

    /// Settings fields.
    private func setupField() {
        [loginField, passField].forEach { field in
            field.autocorrectionType = .no
            field.layer.cornerRadius = 8
            field.leftView = UIView(frame: .init(x: 0, y: 0, width: 4, height: field.frame.height))
            field.leftViewMode = .always
            field.layer.borderWidth = 0.8
            field.layer.backgroundColor = UIColor.darkGray.cgColor
            field.backgroundColor = backgroundColor
        }
    }

    // MARK: - Private Methods

    /// Configuration Rx bindiing.
    private func configureBindingsFields() {
        Observable
            .combineLatest( loginField.rx.text, passField.rx.text )
            .map { [weak self] login, pass in
                guard let self = self else { return false }
                return self.checkFilledFields(minimum: 5, login: login, pass: pass)
            }
            .subscribe { [weak submitButton] inputFilled in
                submitButton?.isEnabled = inputFilled
                submitButton?.backgroundColor = inputFilled ? .gray : .lightGray
            }
            .disposed(by: disposeBag)
    }

    /// Checking completeness of the fields, if the fields are filled the button is activated.
    /// - Parameter minimum: Minimum number of characters  in the field.
    private func checkFilledFields(minimum: Int, login: String?, pass: String?) -> Bool {
        guard let loginCount = login?.count, let passCount = pass?.count else { return false }

        return loginCount >= minimum && passCount >= minimum
    }

    // MARK: - Actions

    /// Submit button action.
    @objc private func submitButtonAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2) {
            sender.transform = CGAffineTransformMakeScale(0.95, 0.95)
        } completion: { [weak self] _ in
            sender.transform = .identity

            guard let self = self,
                  let login = self.loginField.text,
                  let pass = self.passField.text
            else { return }
            
            if self.registerSwitch.isOn {
                self.controller?.viewRequestedRegistration(login, pass)
            } else {
                self.controller?.viewRequestedLogin(login, pass)
            }
        }
    }

    /// Registration switch action.
    @objc private func registerSwitchAction(_ sender: UISwitch) {
        if sender.isOn {
            submitButton.setTitle("Registration", for: .normal)
        } else {
            submitButton.setTitle("Login", for: .normal)
        }
    }
}

// MARK: - LoginViewInput

extension LoginView: LoginViewInput {
    func showAllert(_ tittle: String, _ text: String) {
        let allert = UIAlertController(title: tittle, message: text, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .default)
        allert.addAction(cancelAction)
        controller?.present(allert, animated: true)
    }
}
