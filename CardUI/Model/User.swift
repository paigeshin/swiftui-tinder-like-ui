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
