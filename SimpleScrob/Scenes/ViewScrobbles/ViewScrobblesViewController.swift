//
//  ViewScrobblesViewController.swift
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
import DateToolsSwift

protocol ViewScrobblesDisplayLogic: class {
    func displayScrobbleHistory(viewModel: ViewScrobbles.GetScrobbleHistory.ViewModel)
}

class ViewScrobblesViewController: UITableViewController, ViewScrobblesDisplayLogic {
    var interactor: ViewScrobblesBusinessLogic?
    var router: (NSObjectProtocol & ViewScrobblesRoutingLogic & ViewScrobblesDataPassing)?

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
        let interactor = ViewScrobblesInteractor()
        let presenter = ViewScrobblesPresenter()
        let router = ViewScrobblesRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        interactor.worker = ViewScrobblesWorker(
            database: (UIApplication.shared.delegate as! AppDelegate).database,
            artworkService: (UIApplication.shared.delegate as! AppDelegate).mediaLibrary
        )
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }

    // MARK: Routing

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        
        getScrobbleHistory()
    }

    // MARK: UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scrobbles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongCell
        let scrobble = scrobbles[indexPath.row]
        cell.configure(scrobble: scrobble)        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let cell = tableView.cellForRow(at: indexPath) as? SongCell, cell.expanded {
            let _ = tableView.delegate?.tableView?(tableView, willDeselectRowAt: indexPath)
            tableView.deselectRow(at: indexPath, animated: true)
            tableView.delegate?.tableView?(tableView, didDeselectRowAt: indexPath)
            return nil
        } else {
            return indexPath
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SongCell {
            cell.expand()
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SongCell {
            cell.collapse()
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    // MARK: Get scrobble history

    var scrobbles: [ViewScrobbles.DisplayedScrobble] = []

    func getScrobbleHistory() {
        let request = ViewScrobbles.GetScrobbleHistory.Request()
        interactor?.getScrobbleHistory(request: request)
    }

    func displayScrobbleHistory(viewModel: ViewScrobbles.GetScrobbleHistory.ViewModel) {
        scrobbles = viewModel.scrobbles
        tableView.reloadData()
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        tableView.reloadData()
    }
}
