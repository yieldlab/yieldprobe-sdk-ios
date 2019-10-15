//
//  ViewController.swift
//  Test Host
//
//  Created by Sven Herzberg on 14.10.19.
//

import UIKit

#warning("FIXME: Add SDK configuration.")
#warning("FIXME: Add custom ad slot option.")

let checkmark = "\u{2713}" // U+2713, CHECKMARK: ✓

class ViewController: UITableViewController {
    
    // MARK: Types
    
    enum Section: Int, CaseIterable {
        case sdk
        case adSlot
        case submit
    }
    
    // MARK: Properties
    
    var adSlot: ExampleSlot? {
        didSet {
            dispatchPrecondition(condition: .onQueue(.main))
            
            tableView.reloadSections([Section.adSlot.rawValue, Section.submit.rawValue],
                                     with: .automatic)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int)
        -> String?
    {
        switch Section(rawValue: section) {
        case .sdk:
            return "SDK Configuration"
        case .adSlot:
            return "Ad Slot"
        case .submit:
            fallthrough
        case nil:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        switch Section(rawValue: section) {
        case .sdk:
            return 0
        case .adSlot:
            return 3
        case .submit:
            return 1
        case nil:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        switch Section(rawValue: indexPath.section) {
        case .sdk:
            preconditionFailure()
        case .adSlot:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ad-slot",
                                                     for: indexPath)

            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Banner: 300×250"
                cell.accessoryView?.isHidden = adSlot != .banner300x250
            case 1:
                cell.textLabel?.text = "Banner: 728x90"
                cell.accessoryView?.isHidden = adSlot != .banner728x90
            case 2:
                cell.textLabel?.text = "Video"
                cell.accessoryView?.isHidden = adSlot != .video
            default:
                preconditionFailure()
            }

            return cell
        case .submit:
            precondition(indexPath.row == 0)
            let cell = tableView.dequeueReusableCell(withIdentifier: "submit",
                                                     for: indexPath)
            cell.textLabel?.isEnabled = adSlot != nil
            return cell
        case nil:
            preconditionFailure()
        }
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
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView,
                            willSelectRowAt indexPath: IndexPath)
        -> IndexPath?
    {
        if Section(rawValue: indexPath.section) == .submit && adSlot == nil {
            // Not ready to submit.
            return nil
        }
        
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch Section(rawValue: indexPath.section) {
        case .adSlot:
            switch indexPath.row {
            case 0:
                adSlot = .banner300x250
            case 1:
                adSlot = .banner728x90
            case 2:
                adSlot = .video
            default:
                preconditionFailure()
            }
        case .sdk, .submit:
            break
        case nil:
            preconditionFailure()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let vc as ValidationViewController:
            vc.adSlot = adSlot?.rawValue
        default:
            break
        }
    }
    
}
