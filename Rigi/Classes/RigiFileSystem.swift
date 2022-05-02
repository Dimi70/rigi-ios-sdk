//
//  RigiFileSystem.swift
//  Rigi
//
//  Created by Dimitri van Oijen on 02/05/2022.
//

import Foundation

class RigiFileSystem {

    static var rigiDir: String? {
        guard let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
            else { return nil }
        return dir + "/rigi/"
    }
}
