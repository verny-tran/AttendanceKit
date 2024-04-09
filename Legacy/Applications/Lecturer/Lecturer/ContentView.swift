//
//  ContentView.swift
//  Lecturer
//
//  Created by Trần T. Dũng  on 31/07/2022.
//

import SwiftUI
import Charts
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var launchManager: LaunchManager
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text("ITITIU18247 attendance report")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Chart {
                        BarMark(
                            x: .value("Mount", "July 29"),
                            y: .value("Value", 80)
                        )
                        BarMark(
                            x: .value("Mount", "August 5"),
                            y: .value("Value", 75)
                        )
                        BarMark(
                            x: .value("Mount", "August 12"),
                            y: .value("Value", 90)
                        )
                    }
                    .foregroundColor(Color("DarkBlueColor"))
                    .frame(height: 250)
                    
                    Text("Artificial Intelligence class Friday morning")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .navigationTitle(Text("👩‍🏫 Lecturer"))
        }
        .onAppear {
            DispatchQueue.main
                .asyncAfter(deadline: .now() + 0.7) {
                    launchManager.dismiss()
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
