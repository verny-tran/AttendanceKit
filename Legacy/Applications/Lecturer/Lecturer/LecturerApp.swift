//
//  LecturerApp.swift
//  Lecturer
//
//  Created by Trần T. Dũng  on 31/07/2022.
//

import SwiftUI

@main
struct LecturerApp: App {
    
    @StateObject var launchManager = LaunchManager()
    
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                
                if launchManager.state != .last {
                    LaunchView()
                }
            }
            .environmentObject(launchManager)
        }
    }
}
