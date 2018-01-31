//
//  Container.swift
//  SimpleScrob
//
//  Created by Josh Freed on 1/31/18.
//  Copyright © 2018 Josh Freed. All rights reserved.
//

import Foundation
import CoreData

class Container {
    static let shared = Container()
    private init() {}

    lazy var playedSongStore: PlayedSongStore = CoreDataPlayedSongStore(container: persistentContainer)
    lazy var mediaItemStore: MediaItemStore = CoreDataMediaItemStore(container: persistentContainer)
    lazy var mediaSource: MediaSource = SongScanner(
        mediaLibrary: mediaLibrary,
        dateGenerator: DateGenerator(),
        mediaItemStore: mediaItemStore
    )
    lazy var lastFM: LastFMAPI = {
        #if DEBUG
            return FakeLastFM()
        #else
            let apiKey = "f27fb27503f9aa73c6f308fd9e3bc7f0"
            let secret = "f0ec0f81ae932843046997ef89ce60cc"
            return LastFM.API(engine: LastFM.RestEngine(apiKey: apiKey, secret: secret))
        #endif
    }()
    lazy var scrobbleService: ScrobbleService = LastFmScrobbleService(api: lastFM)
    lazy var mediaLibrary: MediaLibrary = MediaLibrary.shared
    lazy var signInAuthentication: SignInAuthentication = scrobbleService
    
    // MARK: Core Data
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "SimpleScrob")
        //print(NSPersistentContainer.defaultDirectoryURL())
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}
