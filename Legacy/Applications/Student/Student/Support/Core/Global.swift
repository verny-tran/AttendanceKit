
//
//  Global.swift
//  PersonRez
//
//  Created by Trần T. Dũng  on 31/07/2022.
//

import UIKit
import CoreML
import RealmSwift

//Machine Learning Model
let fnet = FaceNet()
let fDetector = FaceDetector()

var vectorHelper = VectorHelper()


let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
let trainingDataset = ImageDataset(split: .train)
let testingDataset = ImageDataset(split: .test)

var currentLabel = UNKNOWN

var numberOfFramesDeteced = 0 //number frames detected
let validFrames = 5 //after getting 5 frames, users have been verified

var attendList: [Users] = [] //load from firebase
var localUserList: [User] = [] //copy of attenList, use it to ignore appended users
var userDict = [String: Int]()

//Save User Local List
let defaults = UserDefaults.standard
var savedUserList = defaults.stringArray(forKey: SAVED_USERS) ?? [String]()


//Realm
let realm = try! Realm()
let fb  = FirebaseManager()

//KMeans to reduce number  of vectors
let KMeans = KMeansSwift.sharedInstance
var kMeanVectors = [Vector]()

//date time formatter
let formatter = DateFormatter()



var current: CGImage?
