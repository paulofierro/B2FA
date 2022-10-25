//
//  Transaction.swift
//  Butterfield2FreeAgent
//
//  Created by Paulo Fierro on 6/30/20.
//  Copyright © 2020 Jadehopper Ltd. All rights reserved.
//

import Foundation
import PFToolbox

/// The structure of a parsed transaction object
struct Transaction {
    
    /// Defines the list of columns found in the CSV file
    enum Column: Int {
        case transactionDate, valueDate, description, debitAmount, creditAmount, balance, reference
    }
    
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
        return Self.outputDateFormatter.string(from: transactionDate)
    }

    var formattedValueDate: String {
        return Self.outputDateFormatter.string(from: valueDate)
    }

    init(with values: [String]) throws {
        
        // Trim the value for a specific column
        let trimValue: (Column) -> String = { column in
            guard let value = values[safeIndex: column.rawValue] else {
                switch column {
                case .reference:
                    return "No reference"
                default:
                    fatalError("Column \(column) has no data")
                }
            }
            return value.trimmed
        }
        
        // Format the dates
        guard
            let tDate = Transaction.inputDateFormatter.date(from: trimValue(.transactionDate)),
            let vDate = Transaction.inputDateFormatter.date(from: trimValue(.valueDate)) else {
            throw "Could not format date from \(values[0])"
        }
        
        transactionDate = tDate
        valueDate = vDate
        reference = trimValue(.reference)
        description = trimValue(.description)
        debit = trimValue(.debitAmount)
        credit = trimValue(.creditAmount)
        balance = trimValue(.balance)
    }
}

private extension Transaction {
    
    private static let locale = Locale(identifier: "en_US_POSIX")
    
    static var inputDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MM yyyy"
        formatter.locale = locale
        return formatter
    }

    static var outputDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = locale
        return formatter
    }
}
