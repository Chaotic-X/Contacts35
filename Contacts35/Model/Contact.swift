//
//  Contact.swift
//  Contacts35
//
//  Created by Alex Lundquist on 8/21/20.
//

import Foundation
import CloudKit

//MARK: -Constant Strings
struct ContactStrings {
	static let recordTypeKey = "Contact"
	fileprivate static let nameKey = "name"
	fileprivate static let phoneNumberKey = "phoneNumber"
	fileprivate static let emailKey = "email"
	
}
class Contact {
	//MAR: -Properties
	var name: String
	var phoneNumber: String
	var email: String
	var recordID: CKRecord.ID
	
	//MARK: -Memberwise Inii
	init(name: String, phoneNumber: String, email: String, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
		self.name = name
		self.phoneNumber = phoneNumber
		self.email = email
		self.recordID = recordID
	}
} //End of Class Contact

//MARK: -Extensions
//create CKRecord from contact
extension CKRecord {
	convenience init(contact: Contact) {
		self.init(recordType: ContactStrings.recordTypeKey, recordID: contact.recordID)
		self.setValuesForKeys([
			ContactStrings.nameKey : contact.name,
			ContactStrings.phoneNumberKey : contact.phoneNumber,
			ContactStrings.emailKey : contact.email
		])
	}
}
//create Contact from CKRecord
extension Contact {
	convenience init?(ckRecord: CKRecord){
		guard let name = ckRecord[ContactStrings.nameKey] as? String,
			  let phoneNumber = ckRecord[ContactStrings.phoneNumberKey] as? String,
			  let email = ckRecord[ContactStrings.emailKey] as? String else {return nil}
		self.init(name: name, phoneNumber: phoneNumber, email: email, recordID: ckRecord.recordID)
	}
}

//MARK: -Extension for equatable if there is time.
extension Contact: Equatable {
	static func == (lhs: Contact, rhs: Contact) -> Bool {
		return lhs.name == rhs.name && lhs.phoneNumber == rhs.phoneNumber && lhs.email == rhs.email
	}
}

extension Contact: SearchableRecord {
	func matches(searchTerm: String) -> Bool {
		
		if name.contains(searchTerm) {
				return true
		}else if phoneNumber.contains(searchTerm) {
				return true
		}else if email.contains(searchTerm){
				return true
		}
		return false
	}
}
