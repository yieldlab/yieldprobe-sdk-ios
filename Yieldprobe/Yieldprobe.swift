//
//  Yieldprobe.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 01.10.19.
//

import Combine
import Foundation

public class Bid {
    
    // Call can throw if the bid is expired.
    // Call can throw if called twice.
    func customTargeting () throws -> [AnyHashable: Any] {
        fatalError("Unimplemented.")
    }
    
}

@available(swift, introduced: 5.0)
public class Yieldprobe: NSObject {
    
    let http: HTTPClient
    
    public static let shared = Yieldprobe()
    
    override init () {
        let configuration = URLSessionConfiguration.default
        self.http = URLSession(configuration: configuration)
    }
    
    init (http: HTTPClient) {
        self.http = http
    }
    
    public func configure (using configuration: Configuration) {
        fatalError("Unimplemented.")
    }
    
    public func probe (slot: Int, completion: @escaping (Result<Bid,Error>) -> Void) {
        probe(slots: [slot]) { (result: Result<[Int : Bid], Error>) -> Void in
            fatalError("Unimplemented.")
        }
    }
    
    public func probe (slots: Set<Int>,
                       completion: @escaping (Result<[Int: Bid],Error>) -> Void)
    {
        #warning("FIXME: Make sure slot ids are positive.")
        #warning("FIXME: Make sure there is at least one ad slot.")
        #warning("FIXME: Make sure the limit of 10 ad slots is being respected.")
        let baseURL = URL(string: "https://ad.yieldlab.net/yp/?content=json")!
        let url = baseURL.appendingPathComponent(slots.map(String.init(_:)).joined(separator: ","))
        _ = http.dataTask(with: url) { result in
            fatalError("Unimplemented.")
            #if false
            guard let _ = data, let _ = response else {
                #warning("FIXME: Handle errors.")
                fatalError("Handle error: \(error!)")
            }
            
            completion()
            #endif
        }
    }
    
}

@available(iOS, introduced: 13.0)
extension Yieldprobe {
    
    public func probe (slot: Int) -> Future<Bid,Error> {
        Future { completion in
            self.probe(slot: slot, completion: completion)
        }
    }

    public func probe (slots: Set<Int>) -> Future<[Int: Bid],Error> {
        Future { completion in
            self.probe(slots: slots, completion: completion)
        }
    }

}
