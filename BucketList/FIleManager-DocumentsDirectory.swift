//
//  FIleManager-DocumentsDirectory.swift
//  BucketList
//
//  Created by Brandon Glenn on 1/13/22.
//

import Foundation


extension FileManager {
    static var documentsDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
