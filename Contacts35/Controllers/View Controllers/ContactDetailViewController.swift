//
//  ContactDetailViewController.swift
//  Contacts35
//
//  Created by Alex Lundquist on 8/21/20.
//

import UIKit

class ContactDetailViewController: UIViewController, UITextFieldDelegate {
	//MARK: -Outlets
	@IBOutlet weak var nameTextFeild: UITextField! {
		didSet {
			let requiredText = NSAttributedString(string: "Name is required",
												  attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
			nameTextFeild.attributedPlaceholder = requiredText
		}
	}
	@IBOutlet weak var phoneNumberTextField: UITextField!
	@IBOutlet weak var emailTextField: UITextField!
	
	var contact: Contact? {
		didSet {
			loadViewIfNeeded()
			setupView()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	//MARK: -Actions
	@IBAction func saveButtonTapped(_ sender: Any) {
		(self.contact == nil) ? saveContact() : updateContact()
	}
	@IBAction func mainViewtapped(_ sender: Any) {
		nameTextFeild.resignFirstResponder()
		phoneNumberTextField.resignFirstResponder()
		emailTextField.resignFirstResponder()
	}
	
	//MARK: -Helper functions
	func setupView() {
		guard let contact = contact else { return }
		nameTextFeild.text = contact.name
		phoneNumberTextField.text = contact.phoneNumber
		emailTextField.text = contact.email
	}
	
	func saveContact() {
		//		guard let contact = contact  else { return }
		guard let name = nameTextFeild.text,
			  let phoneNumber = phoneNumberTextField.text,
			  let email = emailTextField.text,
			  //Put in Alert Controller after return
			  !name.isEmpty else { return presentNoNameAlertController()}
		ContactController.shared.saveContact(withName: name, withPhoneNumber: phoneNumber, withEmail: email) { (result) in
			DispatchQueue.main.async {
				self.navigationController?.popViewController(animated: true)
			}
		}
	}
	func updateContact() {
		guard let contact = contact else { return }
		guard let name = nameTextFeild.text,
			  let phoneNumber = phoneNumberTextField.text,
			  let email = emailTextField.text,
			  !name.isEmpty else { return presentNoNameAlertController() }
		ContactController.shared.updateContact(contact, newName: name, newNumber: phoneNumber, newEmail: email) { (result) in
			DispatchQueue.main.async {
				self.navigationController?.popViewController(animated: true)
			}
		}
	}
	func presentNoNameAlertController() {
		let alert = UIAlertController(title: "Name Missing", message: "can't leave the\nname field blank!", preferredStyle: .alert)
		let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
		alert.addAction(okayAction)
		present(alert, animated: true, completion: nil)
	}
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}
