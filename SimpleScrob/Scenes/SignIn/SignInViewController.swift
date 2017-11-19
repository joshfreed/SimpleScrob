//
//  SignInViewController.swift
//  SimpleScrob
//
//  Created by Josh Freed on 10/2/17.
//  Copyright (c) 2017 Josh Freed. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol SignInDisplayLogic: class {
    func displaySignIn(viewModel: SignIn.SignIn.ViewModel)
}

class SignInViewController: UIViewController, SignInDisplayLogic {
    var interactor: SignInBusinessLogic?
    var router: (NSObjectProtocol & SignInRoutingLogic & SignInDataPassing)?

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!
    
    // MARK: Object lifecycle

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: Setup

    private func setup() {
        let viewController = self
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        let interactor = SignInInteractor(auth: appDelegate.signInAuthentication)
        let presenter = SignInPresenter()
        let router = SignInRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }

    // MARK: Routing

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "exit" {
            usernameTextField.resignFirstResponder()
            passwordTextField.resignFirstResponder()
        }
        
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }

    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        
        signInButton.layer.cornerRadius = 5

        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        usernameTextField.becomeFirstResponder()
    }
    
    // MARK: Keyboard
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let kbSize = keyboardSize.size
            bottomConstraint.constant = kbSize.height + 32
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        bottomConstraint.constant = 32
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
        })
    }

    // MARK: Sign In

    @IBAction func tappedSignIn(_ sender: UIButton) {
        signIn()
    }
    
    func signIn() {
        errorLabel.isHidden = true
        
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        guard let username = usernameTextField.text, !username.isEmpty else {
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            return
        }
        
        activityIndicator.startAnimating()
        signInButton.setTitle(nil, for: .normal)
        signInButton.isEnabled = false
        
        let request = SignIn.SignIn.Request(username: username, password: password)
        interactor?.signIn(request: request)
    }
    
    func displaySignIn(viewModel: SignIn.SignIn.ViewModel) {
        activityIndicator.stopAnimating()
        signInButton.setTitle("Sign In", for: .normal)
        signInButton.isEnabled = true
        
        if viewModel.success {
            router?.routeToScrobble()
        } else {
            errorLabel.isHidden = false
            // todo display login failed message
        }        
    }
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            signIn()
        }
        return true
    }
}
