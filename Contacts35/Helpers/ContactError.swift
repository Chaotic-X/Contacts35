//
//  ContactError.swift
//  Contacts35
//
//  Created by Alex Lundquist on 8/21/20.
//

import Foundation
enum ContactError: LocalizedError {
	
	case ckError(Error)
	case couldNotUnWrap
	case unexpectedResultsFound
	
	var errorDescription: String {
		switch self {
			case .ckError(let error):
				return "There was an error: \(error.localizedDescription)"
			case .couldNotUnWrap:
				return "Was unable to unwrap this contact, try a different gift"
			case .unexpectedResultsFound:
				return "Unexpected records were returned when trying to delete"
		} //End Switch
	} //End errorDescription Computed Property
} //End of enum
