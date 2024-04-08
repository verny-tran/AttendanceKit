//
//  Directory.swift
//  Student
//
//  Created by Dũng/Verny/서비스개발팀 on 26/12/2023.
//

import Foundation

public struct Directory {
    public static let applicationDocuments: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    @discardableResult
    public func copyIfDoesNotExists(from origin: URL, to destination: URL) -> Bool {
        if !FileManager.default.fileExists(atPath: destination.path) {
            
            do { try FileManager.default.copyItem(at: origin, to: destination); return true }
            catch { print(error.localizedDescription) }
        }
        
        return false
    }

    public static func createDirectory(at url: URL) {
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: false)
    }

    public static func contentsOfDirectory(at url: URL) -> [URL]? {
        try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
    }
    
    public static func contentsOfDirectory(at url: URL, matching predicate: (URL) -> Bool) -> [URL]? {
        self.contentsOfDirectory(at: url)?.filter(predicate)
    }

    public static func removeIfExists(at url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
    
    public static func removeAllData() {
        let trainingFolderURL = Directory.applicationDocuments.appendingPathComponent(Frame.ImageDataset.Purpose.train.folder)
        let testingFolderURL = Directory.applicationDocuments.appendingPathComponent(Frame.ImageDataset.Purpose.test.folder)
        
        try? FileManager.default.removeItem(at: trainingFolderURL)
        try? FileManager.default.removeItem(at: testingFolderURL)
    }
}
