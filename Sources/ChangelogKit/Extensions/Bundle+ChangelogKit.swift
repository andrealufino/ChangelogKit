//
//  Bundle+ChangelogKit.swift
//  
//
//  Created by Andrea Mario Lufino on 02/01/24.
//

import Foundation


extension Bundle {
    static var appVersion: String {
        return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    }
}
