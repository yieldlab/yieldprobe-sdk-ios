//
//  ExtraTargetingController.swift
//  Test Host
//
//  Created by Sven Herzberg on 23.10.19.
//

import UIKit

protocol ExtraTargetingControllerDelegate: class {
    
    func extraTargetingController(_ extraTargetingController: ExtraTargetingController,
                                  didChange extraTargeting: [String: String])
    
}

class ExtraTargetingController: UITableViewController {
    
    var extraTargeting: [String: String] = [:] {
        didSet {
            dispatchPrecondition(condition: .onQueue(.main))
            
            tableView.reloadData()
            delegate?.extraTargetingController(self, didChange: extraTargeting)
        }
    }
    
    weak var delegate: ExtraTargetingControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return extraTargeting.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        assert(indexPath.section == 0)
        
        let key = extraTargeting.keys.sorted()[indexPath.row]
        let value = extraTargeting[key]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "key-value", for: indexPath)
        cell.textLabel?.text = key
        cell.detailTextLabel?.text = value
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration?
    {
        UISwipeActionsConfiguration(actions: [
            UIContextualAction(style: .destructive, title: "Remove") { action, view, completionHandler in
                let key = self.extraTargeting.keys.sorted()[indexPath.row]
                self.extraTargeting[key] = nil
                completionHandler(true)
            }
        ])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Interface Builder Actions
    
    @IBAction
    func onAdd (_ sender: UIBarButtonItem) {
        let vc = UIAlertController(title: "Add Key-Value Pair", message: nil, preferredStyle: .alert)
        vc.addTextField { textField in
            textField.delegate = self
            textField.placeholder = "Key"
            textField.tag = self.keyTag
        }
        vc.addTextField { textField in
            textField.delegate = self
            textField.placeholder = "Value"
            textField.tag = self.valueTag
        }
        vc.addAction(UIAlertAction(title: "Close", style: .cancel))
        vc.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self = self else {
                return
            }
            
            self.extraTargeting[self.key.trimmingCharacters(in: .newlines)] =
                self.value.trimmingCharacters(in: .newlines)
        })
        present(vc, animated: true, completion: nil)
    }
    
    let keyTag = 1
    let valueTag = 2
    
    var key = ""
    var value = ""
    
}

extension ExtraTargetingController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String)
        -> Bool
    {
        guard let text = textField.text as NSString? else {
            return true
        }
        
        let result = text.replacingCharacters(in: range, with: string)
        switch textField.tag {
        case keyTag:
            key = result
        case valueTag:
            value = result
        default:
            break
        }
        
        return true
    }
    
}
