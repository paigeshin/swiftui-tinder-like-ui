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

