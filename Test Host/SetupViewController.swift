//
//  SetupViewController.swift
//  Test Host
//
//  Created by Sven Herzberg on 14.10.19.
//

import CoreLocation
import UIKit

let checkmark = "\u{2713}" // U+2713, CHECKMARK: ✓

class SetupViewController: UITableViewController {
    
    // MARK: Types
    
    enum Section: Int, CaseIterable {
        case sdk
        case adSlot
        case submit
    }
    
    enum SDKRow: Int, CaseIterable {
        case personalizeAds
        case useGeolocation
    }
    
    // MARK: Properties
    
    var adSlot: ExampleSlot? {
        didSet {
            dispatchPrecondition(condition: .onQueue(.main))
            
            tableView.reloadSections([Section.adSlot.rawValue, Section.submit.rawValue],
                                     with: .automatic)
        }
    }
    
    var customAdSlot: Int? // Only used while editing.
    
    let formatter = NumberFormatter()
    
    private(set) var personalizeAds = true
    
    private(set) var useGeolocation = true

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
            return SDKRow.allCases.count
        case .adSlot:
            return ExampleSlot.allCases.count + 1
        case .submit:
            return 1
        case nil:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView,
                   switchCellForRowAt indexPath: IndexPath,
                   title: String,
                   keyPath: ReferenceWritableKeyPath<SetupViewController,Bool>)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "switch",
                                                 for: indexPath) as! SwitchCell
        cell.textLabel?.text = title
        cell.switch.isOn = self[keyPath: keyPath]
        cell.onToggle = { flag in
            self[keyPath: keyPath] = flag
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, sdkCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch SDKRow(rawValue: indexPath.row)! {
        case .personalizeAds:
            return self.tableView(tableView,
                                  switchCellForRowAt: indexPath,
                                  title: "Personalized Ads",
                                  keyPath: \SetupViewController.personalizeAds)
        case .useGeolocation:
            return self.tableView(tableView,
                                  switchCellForRowAt: indexPath,
                                  title: "Use Geolocation",
                                  keyPath: \SetupViewController.useGeolocation)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        switch (indexPath.section, indexPath.row) {
        case (Section.sdk.rawValue, _):
            return self.tableView(tableView, sdkCellForRowAt: indexPath)
        default:
            break
        }
        switch Section(rawValue: indexPath.section) {
        case .adSlot:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ad-slot",
                                                     for: indexPath)
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Banner: 300×250"
                cell.accessoryType = adSlot == .banner300x250 ? .checkmark : .none
            case 1:
                cell.textLabel?.text = "Banner: 728×90"
                cell.accessoryType = adSlot == .banner728x90 ? .checkmark : .none
            case 2:
                cell.textLabel?.text = "Video"
                cell.accessoryType = adSlot == .video ? .checkmark : .none
            default:
                if case .custom(let id) = adSlot {
                    cell.textLabel?.text = "Custom: \(id)"
                    cell.accessoryView?.isHidden = false
                    cell.accessoryType = .checkmark
                } else {
                    cell.textLabel?.text = "Custom…"
                    cell.accessoryView?.isHidden = true
                    cell.accessoryType = .disclosureIndicator
                }
            }

            return cell
        case .submit:
            precondition(indexPath.row == 0)
            let cell = tableView.dequeueReusableCell(withIdentifier: "submit",
                                                     for: indexPath)
            cell.textLabel?.isEnabled = adSlot != nil
            return cell
        case .sdk, nil:
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
        switch (indexPath.section, indexPath.row) {
        case (Section.adSlot.rawValue, let row) where row < ExampleSlot.allCases.count:
            adSlot = ExampleSlot.allCases[indexPath.row]
        case (Section.adSlot.rawValue, _):
            let vc = UIAlertController(title: "Custom Ad Slot",
                                       message: "Enter the Ad Slot you want to test.",
                                       preferredStyle: .alert)
            vc.addTextField { textField in
                textField.delegate = self
                textField.keyboardType = .numberPad
                textField.placeholder = "Custom Ad Slot ID"
            }
            vc.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            vc.addAction(UIAlertAction(title: "Done", style: .default) { _ in
                self.adSlot = self.customAdSlot.flatMap(ExampleSlot.init(rawValue:))
            })
            present(vc, animated: true, completion: nil)
        default:
            break
        }
        switch Section(rawValue: indexPath.section) {
        case .adSlot:
            break
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
            vc.personalizeAds = personalizeAds
            vc.useGeolocation = useGeolocation
        default:
            break
        }
    }
    
    // MARK: - Interface Builder Actions
    
    var locationManager = CLLocationManager()
    
    @IBAction
    func didTapSettings (_ sender: UIBarButtonItem) {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
                                      options: [:], completionHandler: nil)
        }
    }
    
}

extension SetupViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String)
        -> Bool
    {
        let text = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        if let adSlotID = text.flatMap(formatter.number(from:)) {
            textField.textColor = .darkText
            self.customAdSlot = adSlotID.intValue
        } else {
            textField.textColor = .systemRed
        }
        return true
    }
    
}
