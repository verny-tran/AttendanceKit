//
//  Helper.swift
//  PersonRez
//
//  Created by Trần T. Dũng  on 31/07/2022.
//

import UIKit

let applicationDocumentsDirectory: URL = {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
}()

@discardableResult func copyIfNotExists(from: URL, to: URL) -> Bool {
    if !FileManager.default.fileExists(atPath: to.path) {
        do {
            try FileManager.default.copyItem(at: from, to: to)
            return true
        } catch {
            print("Error: \(error)")
        }
    }
    return false
}

func removeIfExists(at url: URL) {
    try? FileManager.default.removeItem(at: url)
}

func createDirectory(at url: URL) {
    try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: false)
}

func contentsOfDirectory(at url: URL) -> [URL]? {
    try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
}

func removeAllData() {
    let url1 = applicationDocumentsDirectory.appendingPathComponent("train")
    let url2 = applicationDocumentsDirectory.appendingPathComponent("test")
    
    try? FileManager.default.removeItem(at: url1)
    try? FileManager.default.removeItem(at: url2)
}

func contentsOfDirectory(at url: URL, matching predicate: (URL) -> Bool) -> [URL] {
    contentsOfDirectory(at: url)?.filter(predicate) ?? []
}




