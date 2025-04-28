//
//  LocationSearchService.swift
//  fleetManagementSystem
//
//  Created by user@61 on 28/04/25.
//

import SwiftUI
import MapKit

class LocationSearchService: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var queryFragment = "" {
        didSet {
            completer.queryFragment = queryFragment
        }
    }
    @Published var searchResults: [MKLocalSearchCompletion] = []

    private var completer: MKLocalSearchCompleter

    override init() {
        self.completer = MKLocalSearchCompleter()
        super.init()
        self.completer.resultTypes = [.address, .pointOfInterest]
        self.completer.delegate = self
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("❌ Location search failed: \(error.localizedDescription)")
    }
    
    func selectLocation(completion: MKLocalSearchCompletion, completionHandler: @escaping (CLLocationCoordinate2D?) -> Void) {
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            if let coordinate = response?.mapItems.first?.placemark.coordinate {
                completionHandler(coordinate)
            } else {
                completionHandler(nil)
            }
        }
    }
}
