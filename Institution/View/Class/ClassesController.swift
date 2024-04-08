//
//  ClassesController.swift
//  Institution
//
//  Created by Dũng/Verny/서비스개발팀 on 17/03/2024.
//

import General
import UIKit
import CoreNFC

import RxCocoa
import RxSwift

class ClassesController: UIViewController, UISearchBarDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchResult = BehaviorRelay<[String : [String : Any]]>(value: [:])
    let disposeBag = DisposeBag()
    
    var session: NFCNDEFReaderSession?
    
    var classID: String?
    var className: String?
    var room: String?
    var duration: TimeInterval?
    
    var identifiers = [String]()
    var classes = [String : [String : Any]]() {
        didSet {
            self.identifiers = self.classes.map({ $0.key })
            self.searchResult.accept(self.classes)
        }
    }
    
    var onSelect: (([String : [String : Any]]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dismissKeyboardInteractively()
        self.binding()
        
        self.tableView.delegate = self
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        guard Reachability.isConnectedToInternet
        else { return self.showDialog(message: "You have not connected to internet. Using local data.") }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refresh()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ClassController": let classController = segue.destination as? ClassController
            classController?.classID = self.classID
            classController?.className = self.className
            classController?.room = self.room
            classController?.duration = self.duration
            
        default: break
        }
    }
    
    @objc
    private func refresh() {
        self.tableView.refreshControl?.beginRefreshing()
        
        Firebase.manager.loadClasses { [weak self] classes in
            guard let `self` = self else { return }
            self.classes = classes
            
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    private func binding() {
        self.searchBar.rx.text.orEmpty
            .debounce(.milliseconds(250), scheduler: MainScheduler.instance)
            .distinctUntilChanged().subscribe(onNext: { query in
                let filteredLecturers = self.classes.filter { $0.key.lowercased().hasPrefix(query.lowercased()) }
                self.searchResult.accept(filteredLecturers)
            }).disposed(by: self.disposeBag)
        
        self.searchResult.asObservable().bind(to: self.tableView.rx.items(
            cellIdentifier: "cellID", cellType: UITableViewCell.self
        )) { row, data, cell in
            guard let name = data.value["name"] as? String else { return }
            cell.textLabel?.text = "\(data.key). \(name)"
        }.disposed(by: self.disposeBag)
    }
    
    private func handle(_ ndefStatus: NFCNDEFStatus, in session: NFCNDEFReaderSession, of tag: NFCNDEFTag) {
        guard let room = self.room else { self.showDialog(message: "Missing classroom information."); return }
        
        switch ndefStatus {
        case .notSupported:
            session.alertMessage = "Tag is not NDEF compliant."
            session.invalidate()
            
        case .readOnly:
            session.alertMessage = "Tag is read only."
            session.invalidate()
            
        case .readWrite:
            let uriPayload = NFCNDEFPayload.wellKnownTypeURIPayload(
                string: "student://class?room=\(room)"
            )!

            let message = NFCNDEFMessage(records: [uriPayload])
            
            tag.writeNDEF(message, completionHandler: { error in
                if let error = error { session.alertMessage = "Write NDEF message fail: \(error)" }
                else { session.alertMessage = "Write NDEF message successful." }
                
                session.invalidate()
            })
            
        @unknown default:
            session.alertMessage = "Unknown NDEF tag status."
            session.invalidate()
        }
    }
}

extension ClassesController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        let id = self.identifiers[indexPath.row]
        
        guard let `class` = self.classes[id] else { return }
        self.onSelect?([id : `class`])
        
        self.dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let id = self.identifiers[indexPath.row]
        
        guard let room = self.classes[id]?["room"] as? String,
              let name = self.classes[id]?["name"] as? String else { return nil }
        
        self.room = room
        
        let action = UIContextualAction(style: .normal, title: "Write NFC tag") { _,_,_ in
            guard NFCNDEFReaderSession.readingAvailable else {
                let alertController = UIAlertController(
                    title: "Scanning Not Supported",
                    message: "This device doesn't support tag scanning.",
                    preferredStyle: .alert
                )
                
                alertController.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            
            self.session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
            self.session?.alertMessage = "Hold your iPhone near an NDEF tag to write the message."
            self.session?.begin()
        }

        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let id = self.identifiers[indexPath.row]
        
        guard let room = self.classes[id]?["room"] as? String,
              let name = self.classes[id]?["name"] as? String,
              let duration = self.classes[id]?["duration"] as? TimeInterval else { return nil }
        
        let action = UIContextualAction(style: .normal, title: "Modify") { _,_,_ in
            self.classID = id
            self.className = name
            self.room = room
            self.duration = duration
            
            self.performSegue(withIdentifier: "ClassController", sender: nil)
        }
        
        action.backgroundColor = UIColor(named: "DarkBlueColor")

        return UISwipeActionsConfiguration(actions: [action])
    }
}

extension ClassesController: NFCNDEFReaderSessionDelegate {
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        /// `Do nothing`.
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        guard tags.count == 1 else {
            /// `Restart polling` in ``500`` `milliseconds`.
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            
            session.alertMessage = "More than 1 tag is detected. Please remove all tags and try again."
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                session.restartPolling()
            })
            
            return
        }
        
        /// `Connect to the found tag` and write an <NDEF> message to it.
        guard let tag = tags.first else { return }
        session.connect(to: tag, completionHandler: { error in
            if let _ = error {
                session.alertMessage = "Unable to connect to tag."
                session.invalidate()
                
                return
            }
            
            tag.queryNDEFStatus(completionHandler: { ndefStatus, capacity, error in
                if let _ = error {
                    session.alertMessage = "Unable to query the NDEF status of tag."
                    session.invalidate()
                    
                    return
                }
                
                self.handle(ndefStatus, in: session, of: tag)
            })
        })
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        /// Check the `invalidation reason` from the returned error.
        if let readerError = error as? NFCReaderError {
            /// Show an alert when the invalidation reason is not because of a successful read
            /// during a single-tag read session, or because the user canceled a multiple-tag read session
            /// from the UI or programmatically using the invalidate method call.
            
            guard (readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead)
                    && (readerError.code != .readerSessionInvalidationErrorUserCanceled) else { return }
            
            let alertController = UIAlertController(
                title: "Session Invalidated",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            DispatchQueue.main.async {
                self.present(alertController, animated: true, completion: nil)
            }
        }

        /// To read new tags, a `new session instance is required`.
        self.session = nil
    }
}
