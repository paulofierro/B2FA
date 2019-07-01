//
//  main.swift
//  Butterfield2FreeAgent
//
//  Created by Paulo Fierro on 01/07/2019.
//  Copyright © 2019 Jadehopper Ltd. All rights reserved.
//

import Foundation

/// The structure of a parsed transaction object
struct Transaction {
    let transactionDate: Date
    let valueDate: Date
    let reference: String
    let description: String
    let debit: String
    let credit: String
    let balance: String

    var isDebit: Bool {
        return debit != "0.00" && credit == "0.00"
    }

    var formattedTransactionDate: String {
        return Transaction.outputDateFormatter.string(from: transactionDate)
    }

    var formattedValueDate: String {
        return Transaction.outputDateFormatter.string(from: valueDate)
    }

    init(with values: [String.SubSequence]) throws {
        guard let tDate = Transaction.inputDateFormatter.date(from: values[0].trimmed),
            let vDate = Transaction.inputDateFormatter.date(from: values[1].trimmed) else {
            throw "Could not format date from \(values[0])"
        }
        transactionDate = tDate
        valueDate = vDate
        reference = values[2].trimmed
        description = values[3].trimmed
        debit = values[4].trimmed
        credit = values[5].trimmed
        balance = values[6].trimmed
    }

    private static var inputDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }

    private static var outputDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
}

/// MARK: - Helpers

// Use String as an error
extension String: Error {}

extension Substring {
    /// Remove whitespace, newlines and quotes
    var trimmed: String {
        return String(self)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\"", with: "")
    }
}

/// MARK: - Start Program

// Check we have the right number of arguments
guard CommandLine.arguments.count == 2,
    let path = CommandLine.arguments.last,
    let pathURL = URL(string: "file://\(NSString(string: path).expandingTildeInPath)")
    else {
        print("Usage: Butterfield2FreeAgent ~/path/to/my/file.csv")
        print("Please provide the path to the CSV file to convert.")
        exit(EXIT_FAILURE)
    }

// Set the output path
let outputPath = pathURL.absoluteString
    .replacingOccurrences(of: ".CSV", with: ".csv")
    .replacingOccurrences(of: ".csv", with: "-swift-converted.csv")
guard let outputURL = URL(string: outputPath) else {
    throw "Could not create output URL"
}

// Read the contents
let contents = try String(contentsOf: pathURL)
let lines = contents.split(separator: "\n")

// [HACK!!!]
// For some reason I can't get this to match quite right, as \\d+ doesn't work for the thousands
// so we do two expressions, one for single thousand values (1,000) and another for double (12,000).
/// Not been paid a triple yet...
let singleExpression = try NSRegularExpression(pattern: "\"\\d,\\d+\\.\\d\\d\"", options: [])
let doubleExpression = try NSRegularExpression(pattern: "\"\\d\\d,\\d+\\.\\d\\d\"", options: [])

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
        // Convert "12,345.67" to "12345.67", as otherwise
        // this will screw up the comma-based separation later.
        var string = String(line)
        [singleExpression, doubleExpression].forEach { expression in
            let range = NSRange(location: 0, length: string.count)
            expression
                .enumerateMatches(in: string, options: [], range: range) { result, _, _ in
                    guard let resultRange = result?.range,
                        let range = Range(resultRange, in: string) else {
                        return
                    }
                    let match = string[range]
                    let replacement = String(match).replacingOccurrences(of: ",", with: "")
                    string = expression.stringByReplacingMatches(in: string,
                                                                 options: [],
                                                                 range: resultRange,
                                                                 withTemplate: replacement)

            }
        }
        return string
    }
    .map { line -> Transaction in
        let values = line.split(separator: ",")
        return try Transaction(with: values)
    }

// Create a newline-delimited string that contain all the transactions in the format we need them
let convertedLines = transactions
    .map { transaction -> String in
        let value = transaction.isDebit ? "-" + transaction.debit : transaction.credit
        return [transaction.formattedTransactionDate, value, transaction.description].joined(separator: ",")
    }
    .joined(separator: "\n")
    + "\n" // Add a file newline

// Write to file
do {
    try convertedLines.write(to: outputURL, atomically: true, encoding: .utf8)
} catch {
    print("Could not write file to \(outputURL.absoluteString) due to \(error.localizedDescription)")
    exit(EXIT_FAILURE)
}

print("Converted file and saved as \(outputURL.absoluteString).")
exit(EXIT_SUCCESS)
