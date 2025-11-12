//
//  String+Extensions.swift
//  MoviesAppUIKit
//
//  Created by Raneem Ashraf on 10/11/2025.
//

import Foundation

extension String {
    
    var urlEncoded: String? {
        return addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
    
}
