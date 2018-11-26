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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        DDLog.add(DDOSLogger.sharedInstance) // TTY = Xcode console
        
        #if DEBUG
            Container.shared.lastFM = FakeLastFM()
            Container.shared.mediaLibrary = FakeMediaLibrary()
//            enablePapertrailLogger()
        #else
            enablePapertrailLogger()
        #endif
        
        NotificationCenter.default.addObserver(self, selector: #selector(userSignedIn), name: .signedIn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userSignedOut), name: .signedOut, object: nil)
        
        Container.shared.scrobbleService.resumeSession()
        
        if Container.shared.scrobbleService.isLoggedIn {
            setPapertrailProgramName()
        }
        
        DDLogVerbose("Hi papertrailapp.com")
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        if Container.shared.mediaLibrary.authorizationDenied() {
            window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "MediaAuthDeniedViewController")
        } else if Container.shared.mediaSource.isInitialized {
            window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "ScrobbleViewController")
        } else {
            window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "GetStartedViewController")
        }

        return true
    }
    
    private func enablePapertrailLogger() {
        let paperTrailLogger = RMPaperTrailLogger.sharedInstance()
        paperTrailLogger?.host = "logs6.papertrailapp.com"
        paperTrailLogger?.port = 22232
        paperTrailLogger?.machineName = "SimpleScrob"
        paperTrailLogger?.programName = "no user"
        #if DEBUG
            DDLog.add(paperTrailLogger!)
        #else
            DDLog.add(paperTrailLogger!, with: .debug)
        #endif
    }
    
    private func setPapertrailProgramName() {
        let username = Container.shared.scrobbleService.currentUserName ?? "no user"
        let deviceName = UIDevice.current.name.replacingOccurrences(of: "’", with: "'")
        let vendorId = UIDevice.current.identifierForVendor?.description ?? "nil"
        RMPaperTrailLogger.sharedInstance()?.programName = "\(username)-\(deviceName)"
    }
    
    @objc func userSignedIn() {
        setPapertrailProgramName()
    }
    
    @objc func userSignedOut() {
        setPapertrailProgramName()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        DDLogDebug("applicationWillResignActive")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        DDLogDebug("applicationDidEnterBackground")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        RMPaperTrailLogger.sharedInstance()?.disconnectAfterReadingAndWriting()
        DDLogDebug("applicationWillEnterForeground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        DDLogDebug("applicationDidBecomeActive")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        DDLogDebug("applicationWillTerminate")
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        RMPaperTrailLogger.sharedInstance()?.disconnectAfterReadingAndWriting()
        DDLogInfo("Performing background refresh")
        
        let scrobbleWorker = ScrobbleWorker(
            database: Container.shared.playedSongStore,
            mediaSource: Container.shared.mediaSource,
            scrobbleService: Container.shared.scrobbleService,
            connectivity: AlamofireConnectivity()
        )
        scrobbleWorker.searchForNewSongsToScrobble { songs in
            DDLogDebug("Background refresh complete; found \(songs.count) songs")
            if songs.count > 0 {
                completionHandler(.newData)
            } else {
                completionHandler(.noData)
            }
        }
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
}

struct UserDefaultsKeys {
    static var successfulScrobbleCount: String = "successfulScrobbleCount"
    static var lastAppStoreReviewRequestDate: String = "lastAppStoreReviewRequestDate"    
}
