//
//  ContentView.swift
//  Institution
//
//  Created by Trần T. Dũng  on 31/07/2022.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var launchManager: LaunchManager

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @State private var goToRegister = false
    @State private var goToLecturer = false
    @State private var goToTag = false

    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    ScrollView {
                        HStack {
                            Image("Kit")
                                .resizable()
                                .frame(width: 25, height: 25)
                            
                            Text("AttendanceKit beta v1.0")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top)
                        
                        VStack {
                            CardView(emoji: "👩‍🎓",
                                     task: "Create a new Student Account",
                                     example: "ITITIU18247@student.hcmiu.edu")
                            .onTapGesture {
                                self.goToRegister.toggle()
                            }
                            
                            NavigationLink(destination: RegisterView(), isActive: self.$goToRegister) { EmptyView() }
                            
                            CardView(emoji: "👨‍🏫",
                                     task: "Create a new Lecturer Account",
                                     example: "hnmthong@hcmiu.edu.vn")
                            .onTapGesture {
                                self.goToLecturer.toggle()
                            }
                            
                            NavigationLink(destination: LecturerView(), isActive: self.$goToLecturer) { EmptyView() }
                            
                            CardView(emoji: "👨‍💻",
                                     task: "Manage System Users",
                                     example: "Add or remove a student/lecturer")
                            
                            CardView(emoji: "🪪",
                                     task: "RFID Dashboard Syncing",
                                     example: "E28068942000400563D4B94E")
                            .onTapGesture {
                                self.goToTag.toggle()
                            }
                            
                            NavigationLink(destination: TagView(), isActive: self.$goToTag) { EmptyView() }
                        }
                        
                        VStack {
                            CardView(emoji: "🗓",
                                     task: "Schedule a Class Period",
                                     example: "A2.607")
                            
                            CardView(emoji: "✍️",
                                     task: "Schedule an Examination",
                                     example: "Critical Thinking Final Exam")
                            
                            CardView(emoji: "📊",
                                     task: "View Classes Reports and Analytics",
                                     example: "Attendance report of Calculus 3")
                        }
                        
                        VStack {
                            CardView(emoji: "🎛",
                                     task: "RFID Reader Settings and Configurations",
                                     example: "Room A1.302 reader bandwidth")
                            
                            CardView(emoji: "🔌",
                                     task: "RFID Reader Power Consumption Monitoring",
                                     example: "Room A2.301 reader power consumption")
                        }
                        
                        Text("Copyright ©2022 Trần T. Dũng. All rights reserved.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding()
                    }
                    .onAppear {
                        DispatchQueue.main
                            .asyncAfter(deadline: .now() + 0.7) {
                                launchManager.dismiss()
                            }
                    }
                    .background(Color("BackgroundColor"))
                    .listStyle(InsetGroupedListStyle())
                    .navigationTitle(Text("🏢 Institution"))
                }
                .navigationTitle("Users")
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
