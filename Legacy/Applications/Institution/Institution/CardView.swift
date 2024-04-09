//
//  CardView.swift
//  Institution
//
//  Created by Trần T. Dũng  on 03/08/2022.
//

import SwiftUI

struct CardView: View {
    let emoji: String
    let task: String
    let example: String
    
    var body: some View {
        HStack {
            Text(" ")
                .font(.system(size: 2))
            
            Text(emoji)
                .font(.system(size: 56))
                .padding()
            
            HStack {
                VStack(alignment: .leading) {
                    Text(task)
                        .font(.title2)
                        .fontWeight(.black)
                        .foregroundColor(.primary)
                        .lineLimit(3)
                    Text("E.g: \(example)".uppercased())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                Spacer()
            }
            .background(Color("ForegroundColor"))
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color("DarkBlueColor"), Color("BlueColor")]), startPoint: .top, endPoint: .bottom))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(LinearGradient(gradient: Gradient(colors: [Color("DarkBlueColor"), Color("BlueColor")]), startPoint: .top, endPoint: .bottom), lineWidth: 2)
        )
        .padding([.bottom, .horizontal])
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(emoji: "👩‍🎓",
                 task: "Create a Student Account",
                 example: "ITITIU18247@student.hcmiu.edu")
    }
}
