//
//  ContentView.swift
//  Student
//
//  Created by Trần T. Dũng  on 31/07/2022.
//

import SwiftUI
import CoreData
import UIKit
import AVKit
import Vision
import ARKit
import CoreML
import SceneKit
import Firebase

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var show = false
    
    @State var fullName = ""
    
    private let status = UserDefaults.standard.value(forKey: "status") as? String ?? ""
    
    private let timer = Timer.publish(every: 1,
                                      on: .main,
                                      in: .common).autoconnect()
    @State private var second = 0
    @State private var minute = 0
    @State private var hour = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text("\(status)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding()
                
                Text("\(hour):\(minute):\(second)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .onReceive(timer) { _ in
                        second += 1
                        
                        if second == 61 {
                            second = 0
                            minute += 1
                        }
                        
                        if minute == 61 {
                            minute = 0
                            hour += 1
                        }
                    }
            }
            .navigationTitle(Text("💁‍♂️ Student"))
        }
        .onAppear {
            let name = UserDefaults.standard.value(forKey: "mainUser") as! String
            
            let ref = Database.database().reference()
            ref.child("students").child("\(name)").child("tag").observeSingleEvent(of: .value, with: { snapshot in
                UserDefaults.standard.set(snapshot.value as? String, forKey: "tagID")
            }) { error in
                print(error.localizedDescription)
            }
            
            show.toggle()
        }
        .sheet(isPresented: $show) {
            SwiftUIView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(LaunchManager())
    }
}

struct SwiftUIView: View {
    var body: some View {
        FrameViewControllerRepresentation()
            .edgesIgnoringSafeArea(.all)
    }
}

struct SwiftUIViewController: UIViewControllerRepresentable {
    typealias UIViewControllerType = ARViewController
    
    func makeUIViewController(context: Context) -> ARViewController {
        return ARViewController()
    }
    
    func updateUIViewController(_ uiViewController: ARViewController, context: Context) {
        
    }
    
}
