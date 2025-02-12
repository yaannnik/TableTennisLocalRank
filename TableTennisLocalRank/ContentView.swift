//
//  ContentView.swift
//  TableTennisLocalRank
//
//  Created by 杨挹 on 2/10/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isNavigating = false
    
    var body: some View {
        ZStack {
            Color.red.ignoresSafeArea()
            VStack {
                Image(systemName: "figure.table.tennis").imageScale(.large).colorScheme(.light).padding()
                Text("Table Tennis\nLocal Rankings")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundColor(Color.black)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button(action: {isNavigating = true}){
                    Label("New Session", systemImage: "play")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                NavigationLink(
                    destination: NewSessionView(),
                    isActive: $isNavigating) {
                        EmptyView()
                    }
            }
            .padding(.all)
        }
    }
}

#Preview {
    ContentView()
}
