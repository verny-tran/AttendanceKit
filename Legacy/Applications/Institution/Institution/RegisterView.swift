//
//  RegisterView.swift
//  Institution
//
//  Created by Trần T. Dũng  on 03/08/2022.
//

import SwiftUI
import FirebaseStorage
import Firebase

struct RegisterView: View {
    @State var name = ""
    @State var id = ""
    @State var password = ""
    @State var tag = ""
    
    @State var selectedSchool = "IT"
    @State var selectedMajor = "IT"
    @State var selectedCampus = "IU"
    
    private var school = ["BA", "IT", "EE", "BT", "BE", "CE", "IE", "MA", "EN", "SE", "EV"]
    private var major = ["BA", "FN", "IT", "EE", "EN", "AC", "BT", "FT", "BC", "FT", "BE", "CE", "IE", "LS", "MA", "EN", "SE", "EV"]
    private var campus = ["IU", "NS", "WE", "UH", "SB", "RG", "UN", "NS"]
    
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var selectedImage: UIImage?
    @State private var cameraDisplay = false
    
    @State private var willMove = false
    
    var ref = Database.database().reference()
    
    var body: some View {
        ScrollView {
            HStack(alignment: .top) {
                VStack {
                    ZStack {
                        ZStack {
                            Circle()
                                .strokeBorder(LinearGradient(gradient: Gradient(colors: [Color("DarkBlueColor"), Color("BlueColor")]), startPoint: .top, endPoint: .bottom), lineWidth: 6)
                                .background(Circle().fill(Color("ForegroundColor")))
                                .frame(width: 150, height: 150)
                                .padding()
                            
                            if selectedImage != nil {
                                Image(uiImage: selectedImage!.cropsToSquare()!)
                                    .resizable()
                                    .frame(width: 150, height: 150)
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .strokeBorder(LinearGradient(gradient: Gradient(colors: [Color("DarkBlueColor"), Color("BlueColor")]), startPoint: .top, endPoint: .bottom), lineWidth: 6)
                                    )
                                    .padding()
                                
                                Button(action: {
                                    guard selectedImage != nil else {
                                        return
                                    }
                                    
                                    let storage = Storage.storage()
                                    let storageRef = storage.reference()
                                    
                                    let imageData = selectedImage!.jpegData(compressionQuality: 1)
                                    
                                    guard imageData != nil else {
                                        return
                                    }
                                    
                                    let spaceRef = storageRef.child("studentFaces/\(selectedSchool)\(selectedMajor)\(selectedCampus)\(id).jpg")
                                    
                                    _ = spaceRef.putData(imageData!, metadata: nil) { (metadata, error) in
                                      guard let metadata = metadata else {
                                        // Uh-oh, an error occurred!
                                        return
                                      }
                                      // Metadata contains file metadata such as size, content-type.
                                        _ = metadata.size
                                      // You can also access to download URL after upload.
                                        spaceRef.downloadURL { (url, error) in
                                            guard url != nil else {
                                          // Uh-oh, an error occurred!
                                          return
                                        }
                                      }
                                    }
                                    
                                    let studentID = "\(selectedSchool)\(selectedMajor)\(selectedCampus)\(id)"
                                    self.ref.child("students/\(studentID)/username").setValue(studentID)
                                    self.ref.child("students/\(studentID)/password").setValue(password)
                                    self.ref.child("students/\(studentID)/email").setValue("\(studentID)@student.hcmiu.edu.vn")
                                    self.ref.child("students/\(studentID)/tag").setValue(tag)
                                    self.ref.child("students/\(studentID)/name").setValue(name)
                                    
                                    self.willMove.toggle()
                                }) {
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.system(size: 55))
                                        .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color("DarkBlueColor"), Color("BlueColor")]), startPoint: .top, endPoint: .bottom))
                                }
                                .padding(.leading, 150)
                                .padding(.top, 80)
                                .alert(isPresented: $willMove) {
                                    Alert(title: Text("AttendanceKit"), message: Text("Create new Student Account successfully!"), dismissButton: .default(Text("OK")))
                                }
                            } else {
                                Image(systemName: "faceid")
                                    .font(.system(size: 75))
                                    .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color("DarkBlueColor"), Color("BlueColor")]), startPoint: .top, endPoint: .bottom))
                                    .padding()
                            }
                        }
                        .onTapGesture {
                            self.cameraDisplay.toggle()
                        }
                    }
                    
                    Text("👨‍🎓 Student Information")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    HStack {
                        GeometryReader { geometry in
                            HStack(spacing: 0) {
                                Picker(selection: self.$selectedSchool, label: Text("ID")) {
                                    ForEach(0 ..< 11) { index in
                                        Text("\(self.school[index])").tag(self.school[index])
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(width: geometry.size.width/3, height: 100, alignment: .center)
                                .compositingGroup()
                                .clipped()
                                
                                Picker(selection: self.$selectedMajor, label: Text("ID")) {
                                    ForEach(0 ..< 18) { index in
                                        Text("\(self.major[index])").tag(self.major[index])
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(width: geometry.size.width/3, height: 100, alignment: .center)
                                .compositingGroup()
                                .clipped()
                                
                                Picker(selection: self.$selectedCampus, label: Text("ID")) {
                                    ForEach(0 ..< 8) { index in
                                        Text("\(self.campus[index])").tag(self.campus[index])
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(width: geometry.size.width/3, height: 100, alignment: .center)
                                .compositingGroup()
                                .clipped()
                            }
                        }
                        
                        VStack {
                            TextField("ID", text: $id)
                                .padding()
                                .font(.system(size: 16))
                                .background(Color("ForegroundColor"))
                                .cornerRadius(15)
                                .keyboardType(.numberPad)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(LinearGradient(gradient: Gradient(colors: [Color("DarkBlueColor"), Color("BlueColor")]), startPoint: .top, endPoint: .bottom), lineWidth: 2)
                                )
                            
                            Text("@student.hcmiu.edu.vn")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(height: 120, alignment: .center)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .font(.system(size: 16))
                        .background(Color("ForegroundColor"))
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(LinearGradient(gradient: Gradient(colors: [Color("DarkBlueColor"), Color("BlueColor")]), startPoint: .top, endPoint: .bottom), lineWidth: 2)
                        )
                    
                    TextField("Full name", text: $name)
                        .padding()
                        .font(.system(size: 16))
                        .background(Color("ForegroundColor"))
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(LinearGradient(gradient: Gradient(colors: [Color("DarkBlueColor"), Color("BlueColor")]), startPoint: .top, endPoint: .bottom), lineWidth: 2)
                        )
                    
                    TextField("RFID tag", text: $tag)
                        .padding()
                        .font(.system(size: 16))
                        .background(Color("ForegroundColor"))
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(LinearGradient(gradient: Gradient(colors: [Color("DarkBlueColor"), Color("BlueColor")]), startPoint: .top, endPoint: .bottom), lineWidth: 2)
                        )
                }
                .padding()
                .sheet(isPresented: self.$cameraDisplay) {
                    SwiftUIView()
                }
            }
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}

extension UIPickerView {
   open override var intrinsicContentSize: CGSize {
      return CGSize(width: UIView.noIntrinsicMetric, height: super.intrinsicContentSize.height)}
}

extension UIImage {
    func cropsToSquare() -> UIImage? {
        if let image = self.cgImage {
            let refWidth = CGFloat((image.width))
            let refHeight = CGFloat((image.height))
            let cropSize = refWidth > refHeight ? refHeight : refWidth
            
            let x = (refWidth - cropSize) / 2.0
            let y = (refHeight - cropSize) / 2.0
            
            let cropRect = CGRect(x: x, y: y, width: cropSize, height: cropSize)
            let imageRef = image.cropping(to: cropRect)
            let cropped = UIImage(cgImage: imageRef!, scale: 0.0, orientation: self.imageOrientation)
            return cropped
        }
        return nil
    }
}

struct SwiftUIView: View {
    var body: some View {
        RecordVideoViewControllerRepresentation()
            .edgesIgnoringSafeArea(.all)
    }
}

