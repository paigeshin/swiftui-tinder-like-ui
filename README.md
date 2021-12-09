```swift
//
//  User.swift
//  CardUI
//
//  Created by paige on 2021/12/09.
//

import SwiftUI

struct User: Identifiable {

    var id = UUID().uuidString
    var name: String
    var place: String
    var profilePic: String

}
```

```swift
//
//  HomeViewModel.swift
//  CardUI
//
//  Created by paige on 2021/12/09.
//

import SwiftUI

class HomeViewModel: ObservableObject {

    // Store All the fetched Users here...
    // Since we're building UI so using sample Users here....
    @Published var fetchedUsers: [User] = []

    @Published var displayingUsers: [User]?

    init() {

        // fetching users...
        fetchedUsers = [
            User(name: "Natalia", place: "Vadalia NYC", profilePic: "img1"),
            User(name: "Natalia", place: "Vadalia NYC", profilePic: "img2"),
            User(name: "Natalia", place: "Vadalia NYC", profilePic: "img3"),
            User(name: "Natalia", place: "Vadalia NYC", profilePic: "img1"),
            User(name: "Natalia", place: "Vadalia NYC", profilePic: "img2"),
        ]

        // storing it in displaying users...
        // what is displaying users?
        // it will be updated/removed based on user interaction to reduce memory usage....
        // and the same time we need all the fetched uesrs data....
        displayingUsers = fetchedUsers

    }

    // retreiving index...
    func getIndex(user: User) -> Int {
        let index = displayingUsers?.firstIndex(where: {
            return $0.id == user.id
        }) ?? 0
        return index
    }

}
```

```swift
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
```

```swift
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
```
