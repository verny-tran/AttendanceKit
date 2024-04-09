//
//  LoginView.swift
//  Student
//
//  Created by Trần T. Dũng  on 05/08/2022.
//

import SwiftUI
import Firebase

struct LoginView: View {
    @EnvironmentObject var launchManager: LaunchManager
    
    @State private var name = ""
    @State private var password = ""
    
    @State private var show = false
    @State private var alert = false
    
    var ref = Database.database().reference()
    
    var body: some View {
        VStack {
            Image("Kit")
                .resizable()
                .frame(width: 100, height: 100)
                .padding()
            
            Text("AttendanceKit v1.0")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            TextField("User Name", text: $name)
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
            
            Button(action: {
                if name != "" || password != "" {
                    ref.child("students").child("\(name)").child("password").observeSingleEvent(of: .value, with: { snapshot in
                        if password == snapshot.value as? String {
                            show.toggle()
                            
                            UserDefaults.standard.set(name, forKey: "mainUser")
                        } else {
                            alert.toggle()
                        }
                    }) { error in
                        print(error.localizedDescription)
                        alert.toggle()
                    }
                } else {
                    alert.toggle()
                }
            }) {
                if #available(iOS 15.0, *) {
                    Image(systemName: "signature")
                        .font(.system(size: 50))
                        .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color("DarkBlueColor"), Color("BlueColor")]), startPoint: .top, endPoint: .bottom))
                        .padding()
                } else {
                    Image(systemName: "signature")
                        .font(.system(size: 50))
                        .foregroundColor(Color("DarkBlueColor"))
                        .padding()
                }
            }
            .alert(isPresented: $alert) {
                Alert(
                    title: Text("Wrong username or password!"),
                    message: Text("Please try again"),
                    dismissButton: .default(Text("Got it."))
                )
            }
            
            Text("Copyright ©2022 Trần T. Dũng. All rights reserved.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding()
        }
        .padding()
        .onAppear {
            DispatchQueue.main
                .asyncAfter(deadline: .now() + 0.7) {
                    launchManager.dismiss()
                }
            
            UserDefaults.standard.set("In class...", forKey: "status")
        }
        .navigate(to: ContentView(), when: $show)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

extension View {
    func navigate<NewView: View>(to view: NewView, when binding: Binding<Bool>) -> some View {
        NavigationView {
            ZStack {
                self
                    .navigationBarTitle("")
                    .navigationBarHidden(true)
                
                NavigationLink(
                    destination: view
                        .navigationBarTitle("")
                        .navigationBarHidden(true),
                    isActive: binding
                ) {
                    EmptyView()
                }
            }
        }
    }
}
