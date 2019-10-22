//
//  SetupViewController.swift
//  Test Host
//
//  Created by Sven Herzberg on 14.10.19.
//

import CoreLocation
import UIKit
import Yieldprobe

let checkmark = "\u{2713}" // U+2713, CHECKMARK: ✓

class SetupViewController: UITableViewController {
    
    // MARK: Types
    
    enum Section: Int, CaseIterable {
        case sdk
        case adSlot
        case submit
    }
    
    enum SDKRow: Int, CaseIterable {
        case appName
        case bundleID
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
    
    var appName: String? {
        didSet {
            dispatchPrecondition(condition: .onQueue(.main))
            
            tableView.reloadRows(at: [IndexPath(row: SDKRow.appName.rawValue, section: Section.sdk.rawValue)],
                                 with: .automatic)
        }
    }
    
    var bundleID: String? {
        didSet {
            dispatchPrecondition(condition: .onQueue(.main))
            
            tableView.reloadRows(at: [IndexPath(row: SDKRow.bundleID.rawValue, section: Section.sdk.rawValue)],
                                 with: .automatic)
        }
    }
    
    var customAdSlot: Int? // Only used while editing.
    
    let formatter = NumberFormatter()
    
    private(set) var personalizeAds = true
    
    var textHandler: Optional<(String?, UITextField) -> Void> = nil
    
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
        case .appName:
            let cell = tableView.dequeueReusableCell(withIdentifier: "key-value", for: indexPath)
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = "App Name"
            
            if let appName = self.appName {
                cell.detailTextLabel?.text = appName
                cell.detailTextLabel?.textColor = nil
            } else {
                cell.detailTextLabel?.text = "none"
                cell.detailTextLabel?.textColor = .yld_secondaryLabel
            }
            return cell
        case .bundleID:
            let cell = tableView.dequeueReusableCell(withIdentifier: "key-value", for: indexPath)
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = "Bundle ID"
            
            if let bundleID = self.bundleID {
                cell.detailTextLabel?.text = bundleID
                cell.detailTextLabel?.textColor = nil
            } else {
                cell.detailTextLabel?.text = "none"
                cell.detailTextLabel?.textColor = .yld_secondaryLabel
            }
            return cell
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
    
    func tableView (_ tableView: UITableView,
                    exampleSlot: ExampleSlot,
                    cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ad-slot",
                                                 for: indexPath)
        switch exampleSlot {
        case .banner300x250:
            cell.textLabel?.text = "Banner: 300×250"
        case .banner728x90:
            cell.textLabel?.text = "Banner: 728×90"
        case .video:
            cell.textLabel?.text = "Video"
        default:
            preconditionFailure()
        }
        cell.accessoryType = adSlot == exampleSlot ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        switch (indexPath.section, indexPath.row) {
        case (Section.sdk.rawValue, _):
            return self.tableView(tableView, sdkCellForRowAt: indexPath)
        case (Section.adSlot.rawValue, let row) where row < ExampleSlot.allCases.count:
            return self.tableView(tableView, exampleSlot: ExampleSlot.allCases[row], cellForRowAt: indexPath)
        case (Section.adSlot.rawValue, ExampleSlot.allCases.count):
            let cell = tableView.dequeueReusableCell(withIdentifier: "key-value",
                                                     for: indexPath)
            cell.textLabel?.text = "Custom"
            if case .custom(let id) = adSlot {
                cell.accessoryView?.isHidden = false
                cell.accessoryType = .checkmark
                cell.detailTextLabel?.text = "\(id)"
                cell.detailTextLabel?.textColor = nil
            } else {
                cell.accessoryView?.isHidden = true
                cell.accessoryType = .disclosureIndicator
                cell.detailTextLabel?.text = "none"
                cell.detailTextLabel?.textColor = .yld_secondaryLabel
            }
            return cell
        case (Section.submit.rawValue, 0):
            let cell = tableView.dequeueReusableCell(withIdentifier: "submit",
                                                     for: indexPath)
            cell.textLabel?.isEnabled = adSlot != nil
            return cell
        default:
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
    
    func presentAlert (title: String,
                       message: String,
                       keyboardType: UIKeyboardType? = nil,
                       placeholder: String,
                       submitHandler: @escaping () -> Void = {},
                       textHandler: @escaping (String?, UITextField?) -> Void)
    {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)

        vc.addTextField { textField in
            textField.delegate = self
            if let keyboardType = keyboardType {
                textField.keyboardType = keyboardType
            }
            textField.placeholder = placeholder
            self.textHandler = textHandler
        }
        
        vc.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            textHandler(nil, nil)
            self.textHandler = nil
        }))
        
        vc.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
            self.textHandler = nil
            submitHandler()
        }))
        
        present(vc, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch (indexPath.section, indexPath.row) {
        case (Section.sdk.rawValue, SDKRow.appName.rawValue):
            presentAlert(title: "Custom App Name",
                         message: "Enter the app name you want to test.",
                         placeholder: "Amazing App") { [weak self] text, textField in
                            self?.appName = text
            }
        case (Section.sdk.rawValue, SDKRow.bundleID.rawValue):
            presentAlert(title: "Custom Bundle ID",
                         message: "Enter the bundle ID you want to test.",
                         placeholder: "com.example.Amazing-App") { [weak self] text, textField in
                            self?.bundleID = text
            }
        case (Section.adSlot.rawValue, let row) where row < ExampleSlot.allCases.count:
            adSlot = ExampleSlot.allCases[indexPath.row]
        case (Section.adSlot.rawValue, _):
            presentAlert(title: "Custom Ad Slot",
                         message: "Enter the Ad Slot you want to test.",
                         keyboardType: .numberPad,
                         placeholder: "Custom Ad Slot ID",
                         submitHandler: { [weak self] in
                            guard let self = self else {
                                return
                            }
                            self.adSlot = self.customAdSlot.flatMap(ExampleSlot.init(rawValue:))
            }) { [weak self] text, textField in
                guard let self = self else {
                    return
                }
                if let adSlotID = text.flatMap(self.formatter.number(from:)) {
                    textField?.textColor = .darkText
                    self.customAdSlot = adSlotID.intValue
                } else {
                    textField?.textColor = .systemRed
                }
            }
        case (Section.sdk.rawValue, _),
             (Section.submit.rawValue, _):
            break
        default:
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
            vc.configuration = Configuration(appName: appName,
                                             bundleID: bundleID,
                                             personalizeAds: personalizeAds,
                                             useGeolocation: useGeolocation)
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
        textHandler?(text, textField)
        return true
    }
    
}
