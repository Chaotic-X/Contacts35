//
//  ContactListTableViewController.swift
//  Contacts35
//
//  Created by Alex Lundquist on 8/21/20.
//

import UIKit

class ContactListTableViewController: UITableViewController {
	//MARK: -Outlets
	@IBOutlet weak var searchBar: UISearchBar!
	//MARK: -Properties
	var isSearching = false
	var resultsArray = [SearchableRecord]()
	var dataSource: [SearchableRecord] {
		return isSearching ? resultsArray : ContactController.shared.contacts
	}
	override func viewDidLoad() {
        super.viewDidLoad()
		self.searchBar.delegate = self
		fetchContactsAndReload()
    }
	//MARK: -Helper Methods
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		fetchContactsAndReload()
	}
	
	func fetchContactsAndReload() {
		ContactController.shared.fetchContacts { (_) in
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}
	}
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return ContactController.shared.contacts.count
    }
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)
		let contact = ContactController.shared.contacts[indexPath.row]
		cell.textLabel?.text = contact.name
		if contact.phoneNumber == "" && contact.email != ""{
			cell.detailTextLabel?.text = contact.email
		} else if contact.email == "" && contact.phoneNumber != ""{
			cell.detailTextLabel?.text = contact.phoneNumber
		} else {
			cell.detailTextLabel?.text = "Nothing other then name available"
		}
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
			let contactToDelete = ContactController.shared.contacts[indexPath.row]
			guard let index = ContactController.shared.contacts.firstIndex(of: contactToDelete) else { return }
			ContactController.shared.deleteContact(contactToDelete) { (result) in
				switch result {
					case .success(let success):
						if success {
							ContactController.shared.contacts.remove(at: index)
							DispatchQueue.main.async {
								tableView.deleteRows(at: [indexPath], with: .fade)
							}
						}
					case .failure(let error):
						print(error.errorDescription)
				}
			}
        }
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		//Setting Custom Back Button Text
		navigationItem.backBarButtonItem = UIBarButtonItem(
			title: "Cancel", style: .plain, target: nil, action: nil)
		if segue.identifier == "toContactDetaillVC" {
			guard let indexPath = tableView.indexPathForSelectedRow,
				  let destinationVC = segue.destination as? ContactDetailViewController else { return }
			let selectedContact = ContactController.shared.contacts[indexPath.row]
			destinationVC.contact = selectedContact
		}
    }
}

extension ContactListTableViewController: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		resultsArray = ContactController.shared.contacts.filter { $0.matches(searchTerm: searchText) }
		tableView.reloadData()
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		resultsArray = ContactController.shared.contacts
		tableView.reloadData()
		searchBar.text = ""
		searchBar.resignFirstResponder()
	}
	
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		isSearching = true
	}
	
	func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
		isSearching = false
	}
}
