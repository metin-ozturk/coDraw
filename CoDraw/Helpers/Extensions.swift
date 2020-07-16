//
//  Extensions.swift
//  CoDraw
//
//  Created by Metin Öztürk on 14.07.2020.
//  Copyright © 2020 Jora. All rights reserved.
//

import Foundation

extension String {
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}
