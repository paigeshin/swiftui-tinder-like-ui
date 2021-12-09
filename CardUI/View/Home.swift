//
//  Home.swift
//  CardUI
//
//  Created by paige on 2021/12/09.
//

import SwiftUI

struct Home: View {
    
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        
        VStack {
            
            Button {
                
            } label: {
                Image("menu")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 22, height: 22)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(
                Text("Discover")
                    .font(.title.bold())
            )
            .foregroundColor(.black)
            .padding()
            
            // Users Stack...
            ZStack {
                
                if let users = viewModel.displayingUsers {
                    
                    if users.isEmpty {
                        Text("Come back later we can find more matches for you!")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        
                        // Displaying Cards
                        // Cards are reversed since its ZStack...
                        // You can use reverse here...
                        // or you can use while fetching users...
                        ForEach(users.reversed()) { user in
                            
                            // Card View...
                            StackCardView(user: user)
                                .environmentObject(viewModel)
                            
                        }
                        
                    }
                    
                } else {
                    ProgressView()
                }
                
            }
            .padding(.top, 30)
            .padding()
            .padding(.vertical)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Action Buttons
            HStack(spacing: 15) {
                Button {
                    
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                        .padding(13)
                        .background(.gray)
                        .clipShape(Circle())
                }
                Button {
                    doSwipe(rightSwipe: false)
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .black))
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                        .padding(13)
                        .background(.blue)
                        .clipShape(Circle())
                }
                Button {
                    
                } label: {
                    Image(systemName: "star.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                        .padding(13)
                        .background(.yellow)
                        .clipShape(Circle())
                }
                Button {
                    doSwipe(rightSwipe: true)
                } label: {
                    Image(systemName: "suit.heart.fill")
                        .font(.system(size: 15, weight: .black))
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                        .padding(13)
                        .background(.pink)
                        .clipShape(Circle())
                }

            } //: HSTACK
            .padding(.bottom)
            .disabled(viewModel.displayingUsers?.isEmpty ?? false)
            .opacity(viewModel.displayingUsers?.isEmpty ?? false ? 0.6 : 1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        
    }
    
    // removing cards when doing Swipe...
    func doSwipe(rightSwipe: Bool = false) {
        guard let first = viewModel.displayingUsers?.first else {
            return
        }
        
        // Using Notification to post and receiveing in Stack Cards...
        NotificationCenter.default.post(name: NSNotification.Name("ACTIONFROMBUTTON"), object: nil, userInfo: [
            "id": first.id,
            "rightSwipe": rightSwipe
        ])
    }
    
}
