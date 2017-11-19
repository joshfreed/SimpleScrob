//
//  SignInInteractor.swift
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

protocol SignInBusinessLogic {
    func signIn(request: SignIn.SignIn.Request)
}

protocol SignInDataStore {
    
}

protocol SignInAuthentication {
    func authenticate(username: String, password: String, completion: @escaping (_ success: Bool) -> ())
}

class SignInInteractor: SignInBusinessLogic, SignInDataStore {
    var presenter: SignInPresentationLogic?
    let auth: SignInAuthentication
    
    init(auth: SignInAuthentication) {
        self.auth = auth
    }
    
    // MARK: Sign In

    func signIn(request: SignIn.SignIn.Request) {
        auth.authenticate(username: request.username, password: request.password) { success in
            let response = SignIn.SignIn.Response(success: success)
            self.presenter?.presentSignIn(response: response)
        }
    }
}
