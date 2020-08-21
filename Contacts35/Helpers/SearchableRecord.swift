//
//  SearchableResults.swift
//  Contacts35
//
//  Created by Alex Lundquist on 8/21/20.
//

import Foundation
protocol SearchableRecord {
	func matches(searchTerm: String) -> Bool
}
