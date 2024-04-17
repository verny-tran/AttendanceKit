//
//  LaunchView.swift
//  Student
//
//  Created by Trần T. Dũng  on 02/08/2022.
//

import SwiftUI

struct LaunchView: View {
    @EnvironmentObject var launchManager: LaunchManager
    @State private var animating = false
    @State private var scale = false
    
    @State private var sprite = 0
    
    private let timer = Timer.publish(every: 0.3,
                                      on: .main,
                                      in: .common).autoconnect()
    
    private let loading = Timer.publish(every: 0.023,
                                      on: .main,
                                      in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            background
            logo.onReceive(loading) { _ in
                sprite += 1
                if sprite == 45 {
                    sprite = 0
                }
            }
        }
        .onReceive(timer) { input in
            switch launchManager.state {
            case .first:
                withAnimation(.linear) {
                    animating.toggle()
                }
            case .second:
                withAnimation(.easeInOut) {
                    scale.toggle()
                }
            default:
                break
            }
        }
    }
}

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView().environmentObject(LaunchManager())
    }
}

private extension LaunchView {
    var background: some View {
        Color("BackgroundColor")
            .edgesIgnoringSafeArea(.all)
    }
    
    var logo: some View {
        Image("\(sprite)")
            .resizable()
            .frame(width: 200,
                   height: 200,
                   alignment: .center)
            .scaleEffect(animating ? 0.85 : 1)
            .scaleEffect(scale ? UIScreen.main.bounds.size.height / 20 : 1)
            .opacity(scale ? 0 : 1)
    }
}
