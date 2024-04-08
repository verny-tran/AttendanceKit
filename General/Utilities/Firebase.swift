//
//  Firebase.swift
//  Student
//
//  Created by Dũng/Verny/서비스개발팀 on 21/12/2023.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import SDWebImage

public class Firebase {
    public static let manager: Firebase = Firebase()
    
    public init() { FirebaseApp.configure() }
    
    // MARK: Students
    public func loadStudents(completion: @escaping ([String : [String : Any]]) -> Void) {
        Database.database().reference()
            .child(Constant.studentsChild)
            .queryLimited(toLast: 300).observeSingleEvent(of: .value, with: { snapshot in
                guard let data = snapshot.value as? [String : Any] else { completion([:]); return }
                
                let students = data.compactMapValues({ $0 as? [String : Any] })
                completion(students)
                
            }) { error in
                print(error.localizedDescription)
                completion([:])
            }
    }
    
    public func uploadStudent(_ student: (id: String, name: String), completion: @escaping () -> Void) {
        let dict: Dictionary<String, Any> = [
            "name" : student.name
        ]
        
        Database.database().reference()
            .child(Constant.studentsChild).child(student.id)
            .updateChildValues(dict, withCompletionBlock: { error, _ in
                if error == nil { print("Student uploaded.") }
                completion()
            })
    }
    
    public func uploadStudentClass(_ student: (id: String, class: [String : [String : Any]]), completion: @escaping () -> Void) {
        Database.database().reference()
            .child(Constant.studentsChild).child(student.id).child("classes")
            .updateChildValues(student.class, withCompletionBlock: { error, _ in
                if error == nil { print("Student class uploaded.") }
                completion()
            })
    }
    
    public func deleteStudent(_ student: String, completion: @escaping () -> Void) {
        Database.database().reference()
            .child(Constant.studentsChild).child(student).removeValue()
        
        Database.database().reference()
            .child(Constant.passwordsChild).child(student).removeValue()
    }
    
    // MARK: Lecturers
    public func loadLecturers(completion: @escaping ([String : [String : Any]]) -> Void) {
        Database.database().reference()
            .child(Constant.lecturersChild)
            .queryLimited(toLast: 300).observeSingleEvent(of: .value, with: { snapshot in
                guard let data = snapshot.value as? [String : Any] else { completion([:]); return }
                
                let lecturers = data.compactMapValues({ $0 as? [String : Any] })
                completion(lecturers)
                
            }) { error in
                print(error.localizedDescription)
                completion([:])
            }
    }
    
    public func uploadLecturer(_ lecturer: (id: String, name: String), completion: @escaping () -> Void) {
        let dict: Dictionary<String, Any> = [
            "name" : lecturer.name
        ]
        
        Database.database().reference()
            .child(Constant.lecturersChild).child(lecturer.id)
            .updateChildValues(dict, withCompletionBlock: { error, _ in
                if error == nil { print("Lecturer uploaded.") }
                completion()
            })
    }
    
    public func uploadLecturerClass(_ lecturer: (id: String, class: [String : [String : Any]]), completion: @escaping () -> Void) {
        Database.database().reference()
            .child(Constant.lecturersChild).child(lecturer.id).child("classes")
            .updateChildValues(lecturer.class, withCompletionBlock: { error, _ in
                if error == nil { print("Lecturer class uploaded.") }
                completion()
            })
    }
    
    public func deleteLecturer(_ lecturer: String, completion: @escaping () -> Void) {
        Database.database().reference()
            .child(Constant.lecturersChild).child(lecturer).removeValue()
        
        Database.database().reference()
            .child(Constant.passwordsChild).child(lecturer).removeValue()
    }
    
    // MARK: Classes
    public func loadClasses(completion: @escaping ([String : [String : Any]]) -> Void) {
        Database.database().reference()
            .child(Constant.classesChild)
            .queryLimited(toLast: 1000).observeSingleEvent(of: .value, with: { snapshot in
                guard let data = snapshot.value as? [String : Any] else { completion([:]); return }
                
                let classes = data.compactMapValues({ $0 as? [String : Any] })
                completion(classes)
                
            }) { error in
                print(error.localizedDescription)
                completion([:])
            }
    }
    
    public func loadClasses(student: String, completion: @escaping ([String : [String : Any]]) -> Void) {
        Database.database().reference()
            .child(Constant.studentsChild).child(student).child("classes")
            .queryLimited(toLast: 1000).observeSingleEvent(of: .value, with: { snapshot in
                guard let data = snapshot.value as? [String : Any] else { completion([:]); return }
                
                let classes = data.compactMapValues({ $0 as? [String : Any] })
                completion(classes)
                
            }) { error in
                print(error.localizedDescription)
                completion([:])
            }
    }
    
    public func loadClasses(lecturer: String, completion: @escaping ([String : [String : Any]]) -> Void) {
        Database.database().reference()
            .child(Constant.lecturersChild).child(lecturer).child("classes")
            .queryLimited(toLast: 1000).observeSingleEvent(of: .value, with: { snapshot in
                guard let data = snapshot.value as? [String : Any] else { completion([:]); return }
                
                let classes = data.compactMapValues({ $0 as? [String : Any] })
                completion(classes)
                
            }) { error in
                print(error.localizedDescription)
                completion([:])
            }
    }
    
    public func uploadClass(_ class: (id: String, name: String, room: String, date: Date, duration: TimeInterval), completion: @escaping () -> Void) {
        let dict: Dictionary<String, Any> = [
            "name" : `class`.name,
            "room" : `class`.room,
            "date" : `class`.date.formatted(),
            "duration" : `class`.duration,
        ]
        
        Database.database().reference()
            .child(Constant.classesChild).child(`class`.id)
            .updateChildValues(dict, withCompletionBlock: { error, _ in
                if error == nil { print("Class uploaded.") }
                completion()
            })
    }
    
    public func deleteClass(_ class: String, completion: @escaping () -> Void) {
        Database.database().reference()
            .child(Constant.classesChild).child(`class`).removeValue()
    }
    
    // MARK: Passwords
    public func loadPasswords(completion: @escaping ([String : String]) -> Void) {
        Database.database().reference()
            .child(Constant.passwordsChild)
            .queryLimited(toLast: 300).observeSingleEvent(of: .value, with: { snapshot in
                guard let passwords = snapshot.value as? [String : String] else { completion([:]); return }
                completion(passwords)
                
            }) { error in
                print(error.localizedDescription)
                completion([:])
            }
    }
    
    public func uploadPassword(_ password: (id: String, pattern: String), completion: @escaping () -> Void) {
        Database.database().reference()
                .child(Constant.passwordsChild)
                .updateChildValues([password.id : password.pattern], withCompletionBlock: { error, _ in
                    if error == nil { print("Update password.") }
                    completion()
                })
    }
    
    // MARK: Durations
    public func loadAttendances(of name: String, completion: @escaping ([String : [String : TimeInterval]]) -> Void) {
        Database.database().reference()
            .child(Constant.durationsChild).child(name)
            .queryLimited(toLast: 1000).observeSingleEvent(of: .value, with: { snapshot in
                guard let idenfiers = snapshot.value as? [String : Any] else { completion([:]); return }
                
                let attendances = idenfiers.compactMapValues({ idenfier in
                    return idenfier as? [String : TimeInterval]
                })
                
                completion(attendances)
                
            }) { error in
                print(error.localizedDescription)
                completion([:])
            }
    }
    
    public func uploadAttendance(_ attendance: (id: String, class: String, date: Date, duration: TimeInterval), completion: @escaping () -> Void) {
        Database.database().reference()
            .child(Constant.durationsChild).child(attendance.id).child(attendance.class)
            .updateChildValues([attendance.date.asString() : attendance.duration], withCompletionBlock: { error, _ in
                if error == nil { print("Update duration.") }
                completion()
            })
    }
    
    // MARK: Vectors
    public func loadAllVectors(of name: String, completion: @escaping (Result<[Vector], Error>) -> Void) {
        Database.database().reference()
            .child(Constant.allVectors).child(name)
            .queryLimited(toLast: 1000).observeSingleEvent(of: .value, with: { snapshot in
        
                guard let data = snapshot.value as? [String : Any] else { completion(.failure(NSError())); return }
                let values = Array(data).map { $0.1 }
                
                let vectors: [Vector] = values.compactMap({ value in
                    guard let item = value as? NSDictionary else { return nil }
                    
                    guard let name = item["name"] as? String,
                          let vector = item["vector"] as? String,
                          let distance = item["distance"] as? Double else { return nil }
                    
                    return Vector(name: name, vector: vector.asVector(), distance: distance)
                })
                
                completion(.success(vectors))
                
            }) { error in
                completion(.failure(error))
            }
    }
    
    public func uploadAllVectors(_ vectors: [Vector], completion: @escaping () -> Void) {
        for index in 0 ..< vectors.count { let vector = vectors[index]
            
            let branch = "\(vector.name) - \(index)"
            let dict: Dictionary<String, Any> = [
                "name": vector.name,
                "vector": vector.vector.asString(),
                "distance": vector.distance
            ]
            
            Database.database().reference()
                .child(Constant.allVectors).child(vector.name).child(branch)
                .updateChildValues(dict, withCompletionBlock: { error, _ in
                    if error == nil { print("Vector uploaded") }
                    completion()
                })
        }
    }
    
    // MARK: K-Means vectors
    public func loadKMeansVectors(completion: @escaping ([Vector]) -> Void) {
        Database.database().reference()
            .child(Constant.kMeansVectors)
            .queryLimited(toLast: 1000).observeSingleEvent(of: .value, with: { snapshot in
                
                guard let data = snapshot.value as? [String : Any] else { completion([]); return }
                let values = Array(data).map { $0.1 }
                
                let vectors: [Vector] = values.compactMap({ value in
                    guard let item = value as? NSDictionary else { return nil }
                    
                    guard let name = item["name"] as? String,
                          let vector = item["vector"] as? String,
                          let distance = item["distance"] as? Double else { return nil }
                    
                    return Vector(name: name, vector: vector.asVector(), distance: distance)
                })
                
                completion(vectors)
                
            }) { error in
                print(error.localizedDescription)
                completion([])
            }
    }
    
    public func uploadKMeanVectors(_ vectors: [Vector], completion: @escaping () -> Void) {
        for index in 0 ..< vectors.count { let vector = vectors[index]
            
            let branch = "\(vector.name) - \(index)"
            let dict: Dictionary<String, Any> = [
                "name": vector.name,
                "vector": vector.vector.asString(),
                "distance": vector.distance
            ]
            
            Database.database().reference()
                .child(Constant.kMeansVectors).child(branch)
                .updateChildValues(dict, withCompletionBlock: { error, _ in
                    if error == nil { print("Vector uploaded") }
                    completion()
                })
        }
    }
}
