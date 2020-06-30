//
//  Transaction.swift
//  Butterfield2FreeAgent
//
//  Created by Paulo Fierro on 6/30/20.
//  Copyright © 2020 Jadehopper Ltd. All rights reserved.
//

import Foundation

/// The structure of a parsed transaction object
struct Transaction {
    
    /// Defines the list of columns found in the CSV file
    enum Column: Int {
        case transactionDate, valueDate, reference, description, debitAmount, creditAmount, balance
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

    init(with values: [String.SubSequence]) throws {
        
        // Trim the value for a specific column
        let trimValue: ((Column)) -> String = { column in
            return values[column.rawValue].trimmed
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
    
    static var inputDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }

    static var outputDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
}
