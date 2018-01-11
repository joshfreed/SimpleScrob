//
//  SignInPresenter.swift
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

protocol SignInPresentationLogic {
    func presentSignIn(response: SignIn.SignIn.Response)
}

class SignInPresenter: SignInPresentationLogic {
    weak var viewController: SignInDisplayLogic?

    // MARK: Sign in

    func presentSignIn(response: SignIn.SignIn.Response) {
        let viewModel = SignIn.SignIn.ViewModel(error: makeSignInErrorMessage(from: response.error))
        viewController?.displaySignIn(viewModel: viewModel)
    }
    
    private func makeSignInErrorMessage(from error: SignInError?) -> String? {
        guard let error = error else {
            return nil
        }
        
        switch error {
        case .authenticationFailed: return "Login Failed. Please check your username and password and try again."
        case .other(let message): return message
        }
    }
}
