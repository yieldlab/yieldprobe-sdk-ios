//
//  ValidationViewController.swift
//  Test Host
//
//  Created by Sven Herzberg on 14.10.19.
//

import CoreLocation
import UIKit
import Yieldprobe

extension TimeZone {
    
    static let utc = TimeZone(secondsFromGMT: 0)
    
}

class ValidationViewController: UITableViewController {
    
    // MARK: - Types
    
    enum Activity {
        case started(when: UInt64)
        case configure(when: UInt64)
        case requestBid(when: UInt64)
        case bid(when: UInt64, Bid)
        case bidError(when: UInt64, Error)
        case targeting(when: UInt64, [String: Any])
        case targetingError(when: UInt64, Error)
    }
    
    enum ConfigureRows: Int, CaseIterable {
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
    
    var personalizeAds = true
    
    var useGeolocation = true
    
    private(set) var started: UInt64!
    
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
        activities.append(.configure(when: clock.now()))
        
        let configuration = Configuration(personalizeAds: personalizeAds,
                                          useGeolocation: useGeolocation)
        yieldprobe.configure(using: configuration)
        
        requestBid()
    }
    
    func requestBid () {
        activities.append(.requestBid(when: clock.now()))
        
        yieldprobe.probe(slot: adSlot, completionHandler: receive(bid:))
    }
    
    func receive(bid result: Result<Bid,Error>) {
        let now = clock.now()
        var activity: Activity
        var bid: Bid!
        
        do {
            bid = try result.get()
            activity = .bid(when: now, bid)
        } catch {
            activity = .bidError(when: now, error)
        }
        
        DispatchQueue.main.async {
            self.activities.append(activity)
            
            if let bid = bid {
                self.getTargeting(from: bid)
            }
        }
    }
    
    func getTargeting (from bid: Bid) {
        let now = clock.now()
        
        do {
            try activities.append(.targeting(when: now, bid.customTargeting()))
        } catch {
            activities.append(.targetingError(when: now, error))
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
            return 1
        case .bid:
            return 1
        case .bidError:
            return 2
        case .targeting(when: _, let info):
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
            case .personalizeAds:
                cell.textLabel?.text = "Personalize Ads"
                cell.detailTextLabel?.text = personalizeAds ? "yes" : "no"
            case .useGeolocation:
                cell.textLabel?.text = "Geolocation"
                if !useGeolocation {
                    cell.detailTextLabel?.text = "no"
                } else {
                    switch CLLocationManager.authorizationStatus() {
                    case .authorizedAlways, .authorizedWhenInUse:
                        cell.detailTextLabel?.text = "authorized"
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
        case .bidError(when: _, let error):
            let cell = tableView.dequeueReusableCell(withIdentifier: "error",
                                                     for: indexPath)
            cell.textLabel?.text = error.localizedDescription
            return cell
        case .targeting(when: _, let targeting):
            let key = targeting.keys.sorted()[indexPath.row - 1]
            let value = targeting[key]
            let cell = tableView.dequeueReusableCell(withIdentifier: "key-value",
                                                     for: indexPath)
            cell.textLabel?.text = key
            cell.detailTextLabel?.text = value.map(String.init(describing:)) ?? "null"
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
        case .configure(let when):
            cell.textLabel?.text = "Configure SDK"
            cell.detailTextLabel?.isHidden = false
            cell.detailTextLabel?.text = durationText(for: when)
        case .requestBid(let when):
            cell.textLabel?.text = "Request Bid"
            cell.detailTextLabel?.isHidden = false
            cell.detailTextLabel?.text = durationText(for: when)
        case .bid(let when, _):
            cell.textLabel?.text = "Receive Bid"
            cell.detailTextLabel?.isHidden = false
            cell.detailTextLabel?.text = durationText(for: when)
        case .bidError(let when, _):
            cell.textLabel?.text = "Error Occurred"
            cell.detailTextLabel?.isHidden = false
            cell.detailTextLabel?.text = durationText(for: when)
        case .targeting(let when, _):
            cell.textLabel?.text = "Custom Targeting"
            cell.detailTextLabel?.isHidden = false
            cell.detailTextLabel?.text = durationText(for: when)
        case .targetingError(let when, _):
            cell.textLabel?.text = "Error Occurred"
            cell.detailTextLabel?.isHidden = false
            cell.detailTextLabel?.text = durationText(for: when)
        }
        return cell
    }
    
    func durationText (for timestamp: UInt64) -> String {
        let timeInterval = clock.timeInterval(from: started, to: timestamp)
        
        if timeInterval < 0.000_001 {
            return "\(UInt(timeInterval * 1_000_000_000))ns"
        }
        
        if timeInterval < 0.001 {
            return "\(UInt(timeInterval * 1_000_000))µs"
        }
        
        if timeInterval < 1 {
            return "\(UInt(timeInterval * 1_000))ms"
        }
        
        let secondFormatter = NumberFormatter()
        return secondFormatter.string(from: timeInterval as NSNumber)! + "s"
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
