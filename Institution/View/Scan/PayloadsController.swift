//
//  PayloadsController.swift
//  Institution
//
//  Created by Dũng/Verny/서비스개발팀 on 13/03/2024.
//

import General
import UIKit
import CoreNFC

class PayloadsController: UITableViewController, NFCNDEFReaderSessionDelegate {
    let reuseIdentifier = "reuseIdentifier"
    var message: NFCNDEFMessage = .init(records: [])
    var session: NFCNDEFReaderSession?

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.message.records.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        guard let textLabel = cell.textLabel else {
            return cell
        }

        textLabel.text = "Invalid data"

        let payload = self.message.records[indexPath.row]
        switch payload.typeNameFormat {
        case .nfcWellKnown:
            if let url = payload.wellKnownTypeURIPayload() {
                textLabel.text = "URI Payload: \(url.absoluteString)"
                
            } else { let (string, locale) = payload.wellKnownTypeTextPayload()
                
                guard let string = string, let locale = locale else { return UITableViewCell() }
                textLabel.text = "Text Payload: \(string), \(locale)"
            }
            
        case .absoluteURI:
            guard let text = String(data: payload.payload, encoding: .utf8) else { return UITableViewCell() }
            textLabel.text = text
            
        case .media:
            guard let type = String(data: payload.type, encoding: .utf8) else { return UITableViewCell() }
            textLabel.text = "\(payload.typeNameFormat.description): " + type
            
        case .nfcExternal, .empty, .unknown, .unchanged:
            fallthrough
            
        @unknown default:
            textLabel.text = payload.typeNameFormat.description
        }
        
        return cell
    }
    
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
        session.connect(to: tag, completionHandler: { (error: Error?) in
            if nil != error {
                session.alertMessage = "Unable to connect to tag."
                session.invalidate()
                return
            }
            
            tag.queryNDEFStatus(completionHandler: { (ndefStatus: NFCNDEFStatus, capacity: Int, error: Error?) in
                guard error == nil else {
                    session.alertMessage = "Unable to query the NDEF status of tag."
                    session.invalidate()
                    return
                }

                switch ndefStatus {
                case .notSupported:
                    session.alertMessage = "Tag is not NDEF compliant."
                    session.invalidate()
                    
                case .readOnly:
                    session.alertMessage = "Tag is read only."
                    session.invalidate()
                    
                case .readWrite:
                    let message = NFCNDEFMessage.init(records: [])
                    
                    tag.writeNDEF(message, completionHandler: { (error: Error?) in
                        if let error = error { session.alertMessage = "Write NDEF message fail: \(error)" }
                        else { session.alertMessage = "Write NDEF message successful." }
                        
                        session.invalidate()
                    })
                    
                @unknown default:
                    session.alertMessage = "Unknown NDEF tag status."
                    session.invalidate()
                }
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
            
            guard readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead &&
                    readerError.code != .readerSessionInvalidationErrorUserCanceled else { return }
            
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
    }
}
