//
//  StackCardView.swift
//  CardUI
//
//  Created by paige on 2021/12/09.
//

import SwiftUI

struct StackCardView: View {
    
    @EnvironmentObject private var viewModel: HomeViewModel
    let user: User
    
    // Gesture Properties...
    @State var offset: CGFloat = 0
    @GestureState var isDragging = false
    
    @State var endSwipe: Bool = false
    
    var body: some View {
        
        GeometryReader { proxy in
            let size = proxy.size
            let index = CGFloat(viewModel.getIndex(user: user))
            // Showing Next two cards at top like a Stack...
            let topOffset = (index <= 2 ? index : 2) * 15
            
            ZStack {
                
                Image(user.profilePic)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                // Reducing width too...
                    .frame(width: size.width - topOffset, height: size.height)
                    .cornerRadius(15)
                    .offset(y: -topOffset)
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            
        }
        .offset(x: offset)
        .rotationEffect(.init(degrees: getRotation(angle: 8)))
        // about trim.. https://seons-dev.tistory.com/142
        .contentShape(Rectangle().trim(from: 0, to: endSwipe ? 0 : 1)) // 뒤에 있는 카드를 못 선택하게 막는다.
        //        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .updating($isDragging, body: { value, out, _ in
                    out = true
                })
                .onChanged({ value in
                    let translation = value.translation.width
                    offset = (isDragging ? translation : .zero)
                })
                .onEnded({ value in
                    let width = UIScreen.main.bounds.width - 50
                    let translation = value.translation.width
                    let checkingStatus = (translation > 0 ? translation : -translation)
                    withAnimation {
                        if checkingStatus > (width / 2) {
                            // remove card....
                            offset = (translation > 0 ? width : -width) * 2
                            endSwipeActions()
                            
                            if translation > 0 {
                                rightSwipe()
                            } else {
                                leftSwipe()
                            }
                        } else {
                            // reset
                            offset = .zero
                        }
                    }
                })
        )
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ACTIONFROMBUTTON"))) { data in
            guard let info = data.userInfo else { return }
            let id = info["id"] as? String ?? ""
            let rightSwipe = info["rightSwipe"] as? Bool ?? false
            let width = UIScreen.main.bounds.width - 50
            
            if user.id == id {
                
                // removing card...
                withAnimation {
                    offset = (rightSwipe ? width : -width) * 2
                    endSwipeActions()
                    
                    if rightSwipe {
                        self.rightSwipe()
                    } else {
                        leftSwipe()
                    }
                }
            }
            
        }
        
    }
    
    // Rotation
    private func getRotation(angle: Double) -> Double {
        let rotation = (offset / (UIScreen.main.bounds.width - 50)) * angle
        return rotation
    }
    
    private func endSwipeActions() {
        withAnimation(.none) {
            endSwipe = true
            // after the card is moved away removing the card from array to preserve the memory...
            
            // The delay time based on your animation duration...
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let _ = viewModel.displayingUsers?.first {
                    _ = withAnimation {
                        viewModel.displayingUsers?.removeFirst()
                    }
                }
            }
        }
    }
    
    private func leftSwipe() {
        // DO ACTIONS HERE
        print("Left Swiped")
    }
    
    private func rightSwipe() {
        // DO ACTIONS HERE
        print("Right Swiped")
    }
    
}

