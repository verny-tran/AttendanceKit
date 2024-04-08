//
//  Constant.swift
//  Student
//
//  Created by Dũng/Verny/서비스개발팀 on 21/12/2023.
//

import Foundation

public struct Constant {
    /// `Firebase` Database
    public static let logTimes: String = "LogTimes"
    public static let averageVectors: String = "Vectors"
    
    public static let allVectors: String = "All vectors"
    public static let kMeansVectors: String = "K-mean Vectors"
    
    public static let studentsChild: String = "Students"
    public static let lecturersChild: String = "Lecturers"
    public static let classesChild: String = "Classes"
    public static let passwordsChild: String = "Passwords"
    public static let durationsChild: String = "Durations"
    
    public static let storageURL: String = "gs://facenet-e782e.appspot.com"

    /// Define `Unknown`
    public static let unknown: String = "Unknown"
    public static let takePhotoName: String = "Unknown - Take Photo"

    /// `K-Means Clustering` number of <K>
    public static let clusteringNumberOfK: Int = 3

    /// `Realm`
    public static let savedUsers: String = "SavedUserList"

    /// `Date Time` Formatter
    public static let dateFormat: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    public static let validTime: Int = 60
    
    /// After getting **5 frames**, users `have been verified`
    public static let validFrames: Int = 5
    public static var numberOfFramesDeteced: Int = 0
    
    public static var currentLabel = Constant.unknown
}
