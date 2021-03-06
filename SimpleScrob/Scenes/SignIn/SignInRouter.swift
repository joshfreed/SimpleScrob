//
//  SignInRouter.swift
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

@objc protocol SignInRoutingLogic {
    func routeToScrobble()
    func routeDismiss()
}

protocol SignInDataPassing {
    var dataStore: SignInDataStore? { get }
}

class SignInRouter: NSObject, SignInRoutingLogic, SignInDataPassing {
    weak var viewController: SignInViewController?
    var dataStore: SignInDataStore?

    // MARK: Routing

    func routeToScrobble() {
        viewController?.dismiss(animated: true) { [weak self] in
            self?.viewController?.delegate?.loginSuccess()
        }
    }
    
    func routeDismiss() {
        viewController?.dismiss(animated: true, completion: nil)
    }

    // MARK: Navigation

    //func navigateToSomewhere(source: SignInViewController, destination: SomewhereViewController)
    //{
    //  source.show(destination, sender: nil)
    //}

    // MARK: Passing data

    //func passDataToSomewhere(source: SignInDataStore, destination: inout SomewhereDataStore)
    //{
    //  destination.name = source.name
    //}
}
