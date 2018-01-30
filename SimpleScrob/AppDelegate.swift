//
//  AppDelegate.swift
//  SimpleScrob
//
//  Created by Josh Freed on 9/29/17.
//  Copyright © 2017 Josh Freed. All rights reserved.
//

import UIKit
import CoreData
import PaperTrailLumberjack

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private var _database: PlayedSongStore?
    var database: PlayedSongStore {
        get {
            if _database == nil {
                _database = CoreDataPlayedSongStore(container: persistentContainer)
            }
            return _database!
        }
    }
    
    private var _mediaItemStore: MediaItemStore?
    var mediaItemStore: MediaItemStore {
        get {
            if _mediaItemStore == nil {
                _mediaItemStore = CoreDataMediaItemStore(container: persistentContainer)
            }
            return _mediaItemStore!
        }
    }
    
    private var _songScanner: MediaSource?
    var mediaSource: MediaSource {
        get {
            if _songScanner == nil {
                _songScanner = SongScanner(
                    mediaLibrary: MediaLibrary.shared,
                    dateGenerator: DateGenerator(),
                    mediaItemStore: mediaItemStore
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
                let apiKey = "f27fb27503f9aa73c6f308fd9e3bc7f0"
                let secret = "f0ec0f81ae932843046997ef89ce60cc"
                _lastFM = LastFM.API(engine: LastFM.RestEngine(apiKey: apiKey, secret: secret))
                #endif
            }
            return _lastFM!
        }
    }
    
    private var _scrobbleService: ScrobbleService?
    var scrobbleService: ScrobbleService {
        if _scrobbleService == nil {
            _scrobbleService = LastFmScrobbleService(api: lastFM)
        }
        return _scrobbleService!
    }    
    
    var mediaLibrary: MediaLibrary {
        return MediaLibrary.shared
    }

    var signInAuthentication: SignInAuthentication {
        return scrobbleService
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        DDLog.add(DDOSLogger.sharedInstance) // TTY = Xcode console
        
        let paperTrailLogger = RMPaperTrailLogger.sharedInstance()
        #if !DEBUG
        paperTrailLogger?.host = "logs6.papertrailapp.com"
        paperTrailLogger?.port = 22232
        paperTrailLogger?.machineName = "SimpleScrob"
        paperTrailLogger?.programName = "no user"
        DDLog.add(paperTrailLogger!)
        #endif
        
        NotificationCenter.default.addObserver(self, selector: #selector(userSignedIn), name: .signedIn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userSignedOut), name: .signedOut, object: nil)
        
        scrobbleService.resumeSession()
        
        if scrobbleService.isLoggedIn {
            paperTrailLogger?.programName = scrobbleService.currentUserName
        }
        
        DDLogVerbose("Hi papertrailapp.com")
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        if mediaLibrary.authorizationDenied() {
            window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "MediaAuthDeniedViewController")
        } else if mediaSource.isInitialized {
            window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "ScrobbleViewController")
        } else {
            window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "GetStartedViewController")
        }
        
        return true
    }
    
    @objc func userSignedIn() {
        RMPaperTrailLogger.sharedInstance()?.programName = scrobbleService.currentUserName
    }
    
    @objc func userSignedOut() {
        RMPaperTrailLogger.sharedInstance()?.programName = "no user"
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        DDLogVerbose("applicationWillResignActive")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        DDLogVerbose("applicationDidEnterBackground")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        RMPaperTrailLogger.sharedInstance()?.disconnectAfterReadingAndWriting()
        DDLogVerbose("applicationWillEnterForeground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        DDLogVerbose("applicationDidBecomeActive")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        DDLogVerbose("applicationWillTerminate")
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

