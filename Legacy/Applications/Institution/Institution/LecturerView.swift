//
//  LecturerView.swift
//  Institution
//
//  Created by Trần T. Dũng  on 04/08/2022.
//

import SwiftUI
import FirebaseStorage
import Firebase

struct LecturerView: View {
    @State var name = ""
    @State var email = ""
    @State var password = ""
    
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedImage: UIImage?
    @State private var cameraDisplay = false
    
    @State private var willMove = false
    
    var ref = Database.database().reference()
    
    var body: some View {
        ScrollView {
            HStack(alignment: .top) {
                VStack {
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
                                
                                let spaceRef = storageRef.child("lecturerFaces/\"\(email)\".jpg")
                                
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
                                
                                self.ref.child("lecturers/\(email)/username").setValue(email)
                                self.ref.child("lecturers/\(email)/password").setValue(password)
                                self.ref.child("lecturers/\(email)/name").setValue(name)
                            }) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 55))
                                    .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color("DarkBlueColor"), Color("BlueColor")]), startPoint: .top, endPoint: .bottom))
                            }
                            .padding(.leading, 150)
                            .padding(.top, 80)
                            .alert(isPresented: $willMove) {
                                Alert(title: Text("AttendanceKit"), message: Text("Create new Lecturer Account successfully!"), dismissButton: .default(Text("OK")))
                                    }
                        } else {
                            Image(systemName: "photo")
                                .font(.system(size: 75))
                                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color("DarkBlueColor"), Color("BlueColor")]), startPoint: .top, endPoint: .bottom))
                                .padding()
                        }
                    }
                    .onTapGesture {
                        self.cameraDisplay.toggle()
                    }
                    
                    Text("👩‍🏫 Lecturer Information")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    TextField("Full name", text: $name)
                        .padding()
                        .font(.system(size: 16))
                        .background(Color("ForegroundColor"))
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(LinearGradient(gradient: Gradient(colors: [Color("DarkBlueColor"), Color("BlueColor")]), startPoint: .top, endPoint: .bottom), lineWidth: 2)
                        )
                    
                    TextField("Email", text: $email)
                        .padding()
                        .font(.system(size: 16))
                        .background(Color("ForegroundColor"))
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(LinearGradient(gradient: Gradient(colors: [Color("DarkBlueColor"), Color("BlueColor")]), startPoint: .top, endPoint: .bottom), lineWidth: 2)
                        )
                    
                    SecureField("Password", text: $password)
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
                    CameraView(selectedImage: self.$selectedImage, sourceType: self.sourceType)
                        .edgesIgnoringSafeArea(.all)
                }
            }
        }
    }
}

struct LecturerView_Previews: PreviewProvider {
    static var previews: some View {
        LecturerView()
    }
}
