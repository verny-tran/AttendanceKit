//
//  TagView.swift
//  Institution
//
//  Created by Trần T. Dũng  on 04/08/2022.
//

import SwiftUI
import Firebase

struct TagView: View {
    var ref = Database.database().reference()
    @State private var tagID = "fdgdfshfgshfgh"
    private let timer = Timer.publish(every: 0.01,
                                      on: .main,
                                      in: .common).autoconnect()
    
    var body: some View {
        VStack(alignment: .trailing) {
            Button(action: {
                UIPasteboard.general.string = tagID
            }) {
                Text("COPY")
                    .fontWeight(.bold)
                    .font(.largeTitle)
                    .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color("DarkBlueColor"), Color("BlueColor")]), startPoint: .top, endPoint: .bottom))
                if #available(iOS 16.0, *) {
                    Image(systemName: "doc.on.clipboard.fill")
                        .fontWeight(.bold)
                        .font(.largeTitle)
                        .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color("DarkBlueColor"), Color("BlueColor")]), startPoint: .top, endPoint: .bottom))
                } else {
                    // Fallback on earlier versions
                }
            }
            .padding()
            
            Text(tagID)
                .font(.custom("SFMono-Regular", size: 90))
                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color("DarkBlueColor"), Color("BlueColor")]), startPoint: .top, endPoint: .bottom))
                .padding()
                .onReceive(timer) { _ in
                    ref.child("tag").child("currentTag").observeSingleEvent(of: .value, with: { snapshot in
                        self.tagID = snapshot.value as! String
                    }) { error in
                      print(error.localizedDescription)
                    }
                }
        }
        .padding()
    }
}

struct TagView_Previews: PreviewProvider {
    static var previews: some View {
        TagView()
    }
}
