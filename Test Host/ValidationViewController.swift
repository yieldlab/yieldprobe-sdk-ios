//
//  ValidationViewController.swift
//  Test Host
//
//  Created by Sven Herzberg on 14.10.19.
//

import CoreLocation
import UIKit
import Yieldprobe

class ValidationViewController: UITableViewController {
    
    // MARK: - Types
    
    enum Activity {
        case started(when: HighPrecisionClock.Time)
        case configure(duration: TimeInterval)
        case requestBid(duration: TimeInterval, when: HighPrecisionClock.Time)
        case bid(duration: TimeInterval, Bid)
        case bidError(duration: TimeInterval, Error)
        case targeting(duration: TimeInterval, [String: Any])
        case targetingError(duration: TimeInterval, Error)
    }
    
    enum ConfigureRows: Int, CaseIterable {
        case appName
        case bundleID
        case personalizeAds
        case useGeolocation
    }
    
    // MARK: - Properties
    
    private(set) var activities = [Activity]() {
        willSet {
            dispatchPrecondition(condition: .onQueue(.main))
        }
        didSet {
            tableView.reloadData()
        }
    }
    
    var adSlot: Int!

    let clock = HighPrecisionClock()
    
    var configuration: Configuration!
    
    private(set) var started: HighPrecisionClock.Time!
    
    let yieldprobe = Yieldprobe.shared
    
    // MARK: - View Life-Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        start()
    }
    
    // MARK: - Perform Ad Request
    
    func start () {
        started = clock.now()
        activities = [
            .started(when: started)
        ]
        
        self.configure()
    }
    
    func configure () {
        let start = clock.now()
        yieldprobe.configure(using: configuration)
        let end = clock.now()
        activities.append(.configure(duration: end &- start))
        
        requestBid()
    }
    
    func requestBid () {
        let start = clock.now()
        yieldprobe.probe(slot: adSlot, completionHandler: receive(bid:))
        let end = clock.now()
        
        activities.append(.requestBid(duration: end &- start, when: end))
    }
    
    func receive(bid result: Result<Bid,Error>) {
        let now = clock.now()
        var activity: Activity
        var bid: Bid!
        
        guard let last = activities.last, case .requestBid(_, let start) = last else {
            fatalError()
        }
        
        do {
            bid = try result.get()
            activity = .bid(duration: now &- start, bid)
        } catch {
            activity = .bidError(duration: now &- start, error)
        }
        
        DispatchQueue.main.async {
            self.activities.append(activity)
            
            if let bid = bid {
                self.getTargeting(from: bid)
            }
        }
    }
    
    func getTargeting (from bid: Bid) {
        let start = clock.now()
        
        do {
            let targeting = try bid.customTargeting()
            let end = clock.now()
            activities.append(.targeting(duration: end &- start, targeting))
        } catch {
            let end = clock.now()
            activities.append(.targetingError(duration: end &- start, error))
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        activities.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch activities[section] {
        case .started:
            return 1
        case .configure:
            return 1 + ConfigureRows.allCases.count
        case .requestBid:
            return 2
        case .bid:
            return 1
        case .bidError:
            return 2
        case .targeting(_, let info):
            return 1 + info.count
        case .targetingError:
            fatalError()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        if indexPath.row == 0 {
            return self.tableView(tableView, activityCellForRowAt: indexPath)
        }
        
        switch activities[indexPath.section] {
        case .configure(_):
            let cell = tableView.dequeueReusableCell(withIdentifier: "key-value",
                                                     for: indexPath)
            switch ConfigureRows(rawValue: indexPath.row - 1)! {
            case .appName:
                cell.textLabel?.text = "App Name"
                cell.detailTextLabel?.text = configuration.appName?.debugDescription ?? "none"
            case .bundleID:
                cell.textLabel?.text = "Bundle ID"
                cell.detailTextLabel?.text = configuration.bundleID?.debugDescription ?? "none"
            case .personalizeAds:
                cell.textLabel?.text = "Personalize Ads"
                cell.detailTextLabel?.text = configuration.personalizeAds ? "yes" : "no"
            case .useGeolocation:
                cell.textLabel?.text = "Geolocation"
                if !configuration.useGeolocation {
                    cell.detailTextLabel?.text = "no"
                } else {
                    switch CLLocationManager.authorizationStatus() {
                    case .authorizedAlways, .authorizedWhenInUse:
                        cell.detailTextLabel?.text = "authorized"
                    case .denied:
                        cell.detailTextLabel?.text = "denied"
                    case .notDetermined:
                        cell.detailTextLabel?.text = "not determined"
                    case .restricted:
                        cell.detailTextLabel?.text = "restricted"
                    @unknown default:
                        cell.detailTextLabel?.text = "unknown"
                    }
                }
            }
            return cell
        case .bidError(_, let error):
            let cell = tableView.dequeueReusableCell(withIdentifier: "error",
                                                     for: indexPath)
            cell.textLabel?.text = error.localizedDescription
            return cell
        case .targeting(_, let targeting):
            let key = targeting.keys.sorted()[indexPath.row - 1]
            let value = targeting[key]
            let cell = tableView.dequeueReusableCell(withIdentifier: "key-value",
                                                     for: indexPath)
            cell.textLabel?.text = key
            cell.detailTextLabel?.text = value.map(String.init(describing:)) ?? "null"
            return cell
        case .requestBid:
            let cell = tableView.dequeueReusableCell(withIdentifier: "key-value",
                                                     for: indexPath)
            cell.textLabel?.text = "Ad Slot ID"
            cell.detailTextLabel?.text = adSlot.map(String.init(describing:))
            return cell
        case let `default`:
            fatalError("FIXME: Handle: \(`default`)")
        }
    }
    
    func tableView(_ tableView: UITableView, activityCellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "activity",
                                                 for: indexPath)
        switch activities[indexPath.section] {
        case .started:
            cell.textLabel?.text = "Start"
            cell.detailTextLabel?.isHidden = true
        case .configure(let duration):
            cell.textLabel?.text = "Configure SDK"
            cell.detailTextLabel?.isHidden = false
            cell.detailTextLabel?.text = format(duration)
        case .requestBid(let duration, _):
            cell.textLabel?.text = "Request Bid"
            cell.detailTextLabel?.isHidden = false
            cell.detailTextLabel?.text = format(duration)
        case .bid(let duration, _):
            cell.textLabel?.text = "Receive Bid"
            cell.detailTextLabel?.isHidden = false
            cell.detailTextLabel?.text = format(duration)
        case .bidError(let duration, _):
            cell.textLabel?.text = "Error Occurred"
            cell.detailTextLabel?.isHidden = false
            cell.detailTextLabel?.text = format(duration)
        case .targeting(let duration, _):
            cell.textLabel?.text = "Custom Targeting"
            cell.detailTextLabel?.isHidden = false
            cell.detailTextLabel?.text = format(duration)
        case .targetingError(let duration, _):
            cell.textLabel?.text = "Error Occurred"
            cell.detailTextLabel?.isHidden = false
            cell.detailTextLabel?.text = format(duration)
        }
        return cell
    }
    
    func format (_ duration: TimeInterval) -> String {
        if duration < 0.000_001 {
            return "\(UInt(duration * 1_000_000_000))ns"
        }
        
        if duration < 0.001 {
            return "\(UInt(duration * 1_000_000))µs"
        }
        
        if duration < 1 {
            return "\(UInt(duration * 1_000))ms"
        }
        
        let secondFormatter = NumberFormatter()
        return secondFormatter.string(from: duration as NSNumber)! + "s"
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

}
