//
//  ViewScrobblesRouter.swift
//  SimpleScrob
//
//  Created by Josh Freed on 10/8/17.
//  Copyright (c) 2017 Josh Freed. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

@objc protocol ViewScrobblesRoutingLogic {
    //func routeToSomewhere(segue: UIStoryboardSegue?)
}

protocol ViewScrobblesDataPassing {
    var dataStore: ViewScrobblesDataStore? { get }
}

class ViewScrobblesRouter: NSObject, ViewScrobblesRoutingLogic, ViewScrobblesDataPassing {
    weak var viewController: ViewScrobblesViewController?
    var dataStore: ViewScrobblesDataStore?

    // MARK: Routing

    //func routeToSomewhere(segue: UIStoryboardSegue?)
    //{
    //  if let segue = segue {
    //    let destinationVC = segue.destination as! SomewhereViewController
    //    var destinationDS = destinationVC.router!.dataStore!
    //    passDataToSomewhere(source: dataStore!, destination: &destinationDS)
    //  } else {
    //    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    //    let destinationVC = storyboard.instantiateViewController(withIdentifier: "SomewhereViewController") as! SomewhereViewController
    //    var destinationDS = destinationVC.router!.dataStore!
    //    passDataToSomewhere(source: dataStore!, destination: &destinationDS)
    //    navigateToSomewhere(source: viewController!, destination: destinationVC)
    //  }
    //}

    // MARK: Navigation

    //func navigateToSomewhere(source: ViewScrobblesViewController, destination: SomewhereViewController)
    //{
    //  source.show(destination, sender: nil)
    //}

    // MARK: Passing data

    //func passDataToSomewhere(source: ViewScrobblesDataStore, destination: inout SomewhereDataStore)
    //{
    //  destination.name = source.name
    //}
}
