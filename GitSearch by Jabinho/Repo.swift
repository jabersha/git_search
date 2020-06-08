//
//  Repo.swift
//  GitSearch by Jabinho
//
//  Created by Jaber Vieira Da Silva Shamali on 02/06/20.
//  Copyright © 2020 Jaber Vieira Da Silva Shamali. All rights reserved.
//

import SwiftUI

struct Entry: Codable {
    var items: [Item]
}

    struct Item:Codable{

        var id : Int
        var name : String
        var owner : Owner
        var stargazers_count : Int
        var html_url : String

}



    struct Owner:Codable {
            var login : String
            var avatar_url: String
    }

