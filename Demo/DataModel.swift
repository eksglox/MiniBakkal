//
//  DataModel.swift
//  Demo
//
//  Created by mehmet  akyol on 8.12.2020.
//

import UIKit

struct urunModel: Decodable {
    var id : String
    var name : String
    var price : Double
    var currency : String
    var imageUrl : String
    var stock : Int
    
}



