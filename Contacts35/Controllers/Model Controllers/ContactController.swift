//
//  ContactController.swift
//  Contacts35
//
//  Created by Alex Lundquist on 8/21/20.
//

import Foundation
import CloudKit

class ContactController {
	//MARK: -CloudKit publicDB shared
	let publicDB = CKContainer.default().publicCloudDatabase
	//MARK: -Shared Instance
	static let shared = ContactController()
	//MARK: -Source of Truth
	var contacts: [Contact] = []
	
	//MARK: -CRUD
	//Create/Save Contact
	func saveContact(withName name: String, withPhoneNumber phoneNumber: String, withEmail email: String , completion: @escaping(Result<Contact?, ContactError>) -> Void) {
		let newContact = Contact(name: name, phoneNumber: phoneNumber, email: email)
		let contactRecord = CKRecord(contact: newContact)
		publicDB.save(contactRecord) { (recordToSave, error) in
			if let error = error {
				completion(.failure(.ckError(error)))
			}
			guard let recordToSave = recordToSave,
				  let contactToSave = Contact(ckRecord: recordToSave) else { return completion(.failure(.couldNotUnWrap))}
			print("Contact was Saved Successfully")
			self.contacts.append(contactToSave)
			completion(.success(contactToSave))
		}
	}
	//Read/Fetch Contact(s)
	func fetchContacts(completion: @escaping(Result<[Contact]?, ContactError>) -> Void) {
		let predicate = NSPredicate(value: true)
		let query = CKQuery(recordType: ContactStrings.recordTypeKey, predicate: predicate)
		publicDB.perform(query, inZoneWith: nil) { (records, error) in
			if let error = error {
				completion(.failure(.ckError(error)))
			}
			guard let records = records else { return completion(.failure(.couldNotUnWrap))}
			let contacts = records.compactMap({Contact(ckRecord: $0)})
			print("Successfully completed retrieving Contacts")
			self.contacts = contacts
			completion(.success(contacts))
		}
	}
	//Update Contact
	func updateContact(_ contact: Contact, newName: String, newNumber: String, newEmail: String, completion: @escaping(Result<Contact?, ContactError>) -> Void) {
		contact.name = newName
		contact.phoneNumber = newNumber
		contact.email = newEmail
		let record = CKRecord(contact: contact)
		let operation = CKModifyRecordsOperation(recordsToSave: [record])
		operation.savePolicy = .changedKeys
		operation.qualityOfService = .userInteractive
		operation.modifyRecordsCompletionBlock = { (records, _, error) in
			if let error = error {
				completion(.failure(.ckError(error)))
			}
			guard let record = records?.first,
				  let updatedContact = Contact(ckRecord: record) else { return completion(.failure(.couldNotUnWrap))}
			print("We Updated this \(record.recordID) successfully in cloudKit")
			completion(.success(updatedContact))
		}
		publicDB.add(operation)
	}
	//Delete Contact
	func deleteContact(_ contact: Contact, completion: @escaping(Result<Bool, ContactError>) -> Void) {
		let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [contact.recordID])
		operation.savePolicy = .changedKeys
		operation.qualityOfService = .userInteractive
		operation.modifyRecordsCompletionBlock = { (records, _, error) in
			if let error = error {
				return completion(.failure(.ckError(error)))
			}
			if  records?.count == 0 {
				print("Deleted Contact from CloudKit")
				completion(.success(true))
			} else {
				return completion(.failure(.unexpectedResultsFound))
			}
		}
		publicDB.add(operation)
	}
} //End of ContactController Class
