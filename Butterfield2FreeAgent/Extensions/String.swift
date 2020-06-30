//
//  String.swift
//  Butterfield2FreeAgent
//
//  Created by Paulo Fierro on 6/30/20.
//  Copyright © 2020 Jadehopper Ltd. All rights reserved.
//

import Foundation

// Use String as an error
extension String: Error {}

extension String {

    /// Writes the string to file
    func write(to outputPath: String) throws {
        do {
            try self.write(toFile: outputPath, atomically: true, encoding: .utf8)
        } catch {
            B2FA.exit(withError: error)
        }
    }
}


extension Substring {
    /// Remove whitespace, newlines and quotes
    var trimmed: String {
        return String(self)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\"", with: "")
    }
}
