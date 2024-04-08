//
//  ScanController.swift
//  Institution
//
//  Created by Dũng/Verny/서비스개발팀 on 13/03/2024.
//

import General
import UIKit
import CoreNFC

class ScanController: UITableViewController, NFCNDEFReaderSessionDelegate {
    let reuseIdentifier = "reuseIdentifier"
    var detectedMessages = [NFCNDEFMessage]()
    var session: NFCNDEFReaderSession?

    // MARK: Actions
    @IBAction func beginScanning(_ sender: Any) {
        guard NFCNDEFReaderSession.readingAvailable else {
            let alertController = UIAlertController(
                title: "Scanning Not Supported",
                message: "This device doesn't support tag scanning.",
                preferredStyle: .alert
            )
            
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            
            return
        }

        self.session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        self.session?.alertMessage = "Hold your iPhone near the item to learn more about it."
        self.session?.begin()
    }

    // MARK: Conforming
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        DispatchQueue.main.async {
            /// Process `detected` <NFCNDEFMessage> objects.
            self.detectedMessages.append(contentsOf: messages)
            self.tableView.reloadData()
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        if tags.count > 1 {
            /// `Restart polling` in `500 ms`
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            session.alertMessage = "More than 1 tag is detected, please remove all tags and try again."
            
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                session.restartPolling()
            })
            
            return
        }
        
        /// Connect to the `found tag` and perform <NDEF> message reading
        let tag = tags.first!
        session.connect(to: tag, completionHandler: { (error: Error?) in
            if nil != error {
                session.alertMessage = "Unable to connect to tag."
                session.invalidate()
                return
            }
            
            tag.queryNDEFStatus(completionHandler: { (ndefStatus: NFCNDEFStatus, capacity: Int, error: Error?) in
                if .notSupported == ndefStatus {
                    session.alertMessage = "Tag is not NDEF compliant"
                    session.invalidate()
                    
                    return
                    
                } else if nil != error {
                    session.alertMessage = "Unable to query NDEF status of tag"
                    session.invalidate()
                    
                    return
                }
                
                tag.readNDEF(completionHandler: { (message: NFCNDEFMessage?, error: Error?) in
                    var statusMessage: String
                    
                    if nil != error || nil == message {
                        statusMessage = "Fail to read NDEF from tag"
                    } else {
                        statusMessage = "Found 1 NDEF message"
                        DispatchQueue.main.async {
                            /// Process `detected` <NFCNDEFMessage> objects.
                            self.detectedMessages.append(message!)
                            self.tableView.reloadData()
                        }
                    }
                    
                    session.alertMessage = statusMessage
                    session.invalidate()
                })
            })
        })
    }
    
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        /// `Do nothing`.
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
    
    func addMessage(fromUserActivity message: NFCNDEFMessage) {
        DispatchQueue.main.async {
            self.detectedMessages.append(message)
            self.tableView.reloadData()
        }
    }
}

extension ScanController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.detectedMessages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath)

        let message = self.detectedMessages[indexPath.row]
        let description = message.records.first?.typeNameFormat.description ?? NFCTypeNameFormat.nfcWellKnown.description
        let unit = message.records.count == 1 ? " \(description) Payload" : " \(description) Payloads"
        cell.textLabel?.text = message.records.count.description + unit

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = self.tableView.indexPathForSelectedRow,
            let payloadsTableViewController = segue.destination as? PayloadsController else {
            return
        }
        
        payloadsTableViewController.message = detectedMessages[indexPath.row]
    }
}
