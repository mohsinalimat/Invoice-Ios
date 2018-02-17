
import UIKit

class ContactDetailViewController: UITableViewController {

    let numberOfRowsAtSection: [Int] = [4, 1]
    var numberOfSections = 2
    
    var contact: Contact?
    var client: Client?
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.sectionHeaderHeight = 50.0;
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveContact))
    }

    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "New"
        numberOfSections = 1
        if (contact?.client_contact_id) != nil {
            self.title = "Edit"
            firstNameTextField.text = contact?.first_name
            lastNameTextField.text = contact?.last_name
            phoneTextField.text = contact?.phone
            emailTextField.text = contact?.email
        }
    }

    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows: Int = 0
        if section < numberOfRowsAtSection.count {
            rows = numberOfRowsAtSection[section]
        }
        return rows
    }


}


extension ContactDetailViewController {
    
    @objc func saveContact(sender: UIButton!) {
        let firstName = firstNameTextField.text ?? ""
        let lastName = lastNameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let phone = phoneTextField.text ?? ""
        let client_id = client?.client_id ?? nil
        var endPoint: String
        
        if (contact?.client_contact_id) != nil {
            endPoint = "api/contacts/update"
        } else {
            endPoint = "api/contacts/add"
        }
        
        contact = Contact(client_contact_id: contact?.client_contact_id, client_id: client_id,first_name: firstName, last_name: lastName, email: email, phone: phone)
        let requestBody = makeJSONData(client)
        
        makeRequestPost(endpoint: endPoint,
                        requestType: "POST",
                        requestBody: requestBody,
                        view: view,
                        completionHandler: { (response : ApiContainer<Contact>?, error : Error?) in
                            if let error = error {
                                print("error calling POST on /todos")
                                print(error)
                                return
                            }
                            let responseMeta = (response?.meta)!
                            let responseData = (response?.result[0])
                            let client_contact_id = responseData?.client_contact_id
                            self.contact?.client_contact_id = client_contact_id
                            
                            if(responseMeta.sucess == "yes") {
                                let alert = UIAlertController(title: "Order Placed!", message: "Thank you for your order.\nWe'll ship it to you soon!", preferredStyle: .alert)
                                let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
                                    (_)in
                                    self.performSegue(withIdentifier: "unwindToContacts", sender: self)
                                })
                                
                                alert.addAction(OKAction)
                                DispatchQueue.main.async(execute: {
                                    self.present(alert, animated: true, completion: nil)
                                    
                                })
                            }
                            else
                            {
                                DispatchQueue.main.async(execute: {
                                    let myAlert = UIAlertController(title: "Error", message: "Error creating Client", preferredStyle: .alert)
                                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                                    myAlert.addAction(okAction)
                                    self.present(myAlert, animated: true, completion: nil)
                                })
                                return
                            }
        } )
        
    }
    
    @IBAction func btnDelete(_ sender: Any) {
        showDelete()
    }
    
    func showDelete() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let  deleteButton = UIAlertAction(title: "Delete Contact", style: .destructive, handler: { (action) -> Void in
            self.deleteContact()
        })
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })
        alertController.addAction(deleteButton)
        alertController.addAction(cancelButton)
        self.navigationController!.present(alertController, animated: true, completion: nil)
    }
    
    func deleteContact() {
        let client_contact_id : String! = "\(contact!.client_contact_id!)"
        var endPoint: String
        endPoint = "api/contacts/"+client_contact_id+"/delete"
        
        makeRequest(endpoint: endPoint,
                    parameters: [:],
                    completionHandler: { (container : ApiContainer<Client>?, error : Error?) in
                        if let error = error {
                            print("error calling POST on /getClients")
                            print(error)
                            return
                        }
        } )
        
    }
    
}
