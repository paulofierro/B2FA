//
//  Collection.swift
//  Butterfield2FreeAgent
//
//  Created by Paulo Fierro on 6/30/20.
//  Copyright © 2020 Jadehopper Ltd. All rights reserved.
//

import Foundation

extension Collection where Element == Transaction {
    
    func converted() -> String {
        return self
            .map { transaction -> String in
                
                // Find the value
                let value: String
                if transaction.isDebit {
                    value = transaction.debit.contains("-") ? transaction.debit : "-" + transaction.debit
                } else {
                    value = transaction.credit
                }
                
                // Create the list of items
                let items = [
                    transaction.formattedTransactionDate,
                    value,
                    transaction.description
                ]
                return items.joined(separator: ",")
            }
            .joined(separator: "\n")
            + "\n" // Add a newline at the end
    }
}
