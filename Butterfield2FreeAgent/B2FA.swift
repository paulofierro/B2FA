//
//  main.swift
//  Butterfield2FreeAgent
//
//  Created by Paulo Fierro on 01/07/2019.
//  Copyright © 2019 Jadehopper Ltd. All rights reserved.
//

import ArgumentParser
import Foundation
import PFToolbox

@main
struct B2FA: ParsableCommand {
 
    /// The path to the CSV we want to convert.
    @Argument(help: "The path to the CSV file to convert.")
    var path: String
    
    /// The path to the converted CSV.
    var outputPath: String {
        path.replacingOccurrences(of: ".CSV", with: ".csv")
            .replacingOccurrences(of: ".csv", with: "-converted.csv")
    }
    
    /// Entry point
    func run() throws {
        try readTransactions()
            .converted()
            .write(to: outputPath)
        
        log.info("Converted file and saved as \(outputPath).")
    }
}

// MARK: - Private Methods

extension B2FA {
    
    /// Read the contents of the file and convert it to a list of transactions
    private func readTransactions() throws -> [Transaction] {
        let contents = try String(contentsOfFile: path)
        let lines = contents.split(separator: "\n")
        
        // For some reason I can't get this to match quite right, as \\d+ doesn't work for the thousands
        // so we do three expressions.
        let singleExpression = try NSRegularExpression(pattern: "\"\\d,\\d+\\.\\d\\d\"", options: [])
        let doubleExpression = try NSRegularExpression(pattern: "\"\\d\\d,\\d+\\.\\d\\d\"", options: [])
        let tripleExpression = try NSRegularExpression(pattern: "\"\\d\\d\\d,\\d+\\.\\d\\d\"", options: [])
        let quoteExpression = try NSRegularExpression(pattern: "\"(.*)\"", options: [])

        // Remove the non-transaction lines, and create a list of Transaction objects
        var ignoreLine = true
        let transactions = try lines
            .compactMap { line -> String? in
                if line.contains("Transaction Date") {
                    ignoreLine = false
                    return nil
                }

                guard !ignoreLine else {
                    return nil
                }

                // Convert "XY,ABC.DE" to "XYABC.DE", as otherwise
                // this will screw up the comma-based separation later.
                var string = String(line)
                [singleExpression, doubleExpression, tripleExpression, quoteExpression].forEach { expression in
                    let range = NSRange(location: 0, length: string.count)
                    expression
                        .enumerateMatches(in: string, options:[], range: range) { result, flags, pointer in

                            guard let resultRange = result?.range,
                                let range = Range(resultRange, in: string) else {
                                return
                            }

                            let match = string[range]
                            let replacement = String(match).replacingOccurrences(of: ",", with: "")
                            string = expression.stringByReplacingMatches(
                                in: string,
                                options: [],
                                range: resultRange,
                                withTemplate: replacement
                            )

                    }
                }
                return string
            }
            .map { line -> Transaction in
                // If lines don't have a debit or crebit the value is empty which results in ",,"
                // in the transaction line. Unfortunately split() removes this element which results
                // in out of bounds exceptsions, so insert a 0
                let values = line
                    .replacingOccurrences(of: ",,", with: ",0.00,")
                    .split(separator: ",")
                    .map {
                        String($0)
                    }
                return try Transaction(with: values)
            }
        return transactions
    }
}
