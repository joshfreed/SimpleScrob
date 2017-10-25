//
//  AppDelegate.swift
//  SimpleScrob
//
//  Created by Josh Freed on 9/29/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private var _database: Database?
    var database: Database {
        get {
            if _database == nil {
                _database = CoreDataDatabase(container: persistentContainer)
            }
            return _database!
        }
    }
    
    private var _songScanner: SongScanner?
    var songScanner: SongScanner {
        get {
            if _songScanner == nil {
                _songScanner = SongScanner(
                    mediaLibrary: MediaLibrary.shared,
                    database: database,
                    dateGenerator: DateGenerator()
                )
            }
            return _songScanner!
        }
    }
    
    private var _lastFM: LastFMAPI?
    var lastFM: LastFMAPI {
        get {
            if _lastFM == nil {
                #if DEBUG
                _lastFM = FakeLastFM()
                #else
                let apiKey = ""
                let secret = ""
                _lastFM = LastFM.API(engine: LastFM.RestEngine(apiKey: apiKey, secret: secret))
                #endif
            }
            return _lastFM!
        }
    }
    
    private var _batchSongUpdater: BatchSongUpdater?
    var batchSongUpdater: BatchSongUpdater {
        if _batchSongUpdater == nil {
            _batchSongUpdater = BatchSongUpdater(database: database)
        }
        return _batchSongUpdater!
    }
    
    var mediaLibrary: MediaLibrary {
        return MediaLibrary.shared
    }

    let session = Session()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        session.resume()
        _lastFM!.sessionKey = session.sessionKey
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        print("applicationWillResignActive")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("applicationDidEnterBackground")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("applicationWillEnterForeground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("applicationDidBecomeActive")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("applicationWillTerminate")
    }

    // MARK: - Core Data stack
    
    private func deleteDatabase() {
        var url = NSPersistentContainer.defaultDirectoryURL()
        url.appendPathComponent("SimpleScrob.sqlite")
        
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            fatalError("\(error)")
        }
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "SimpleScrob")
        print(NSPersistentContainer.defaultDirectoryURL())
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
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

