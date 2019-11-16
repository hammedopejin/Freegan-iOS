//
//  LocationVC.swift
//  freegan
//
//  Created by Hammed opejin on 7/30/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class LocationVC: UIViewController {
    
    var locationTableView: UITableView!
    var currentLocation: CLLocation?
    lazy var searchCompleter: MKLocalSearchCompleter = {
        let sc = MKLocalSearchCompleter()
        sc.delegate = self
        return sc
    }()
    let searchController = UISearchController(searchResultsController: nil)
    var searchResults = [MKLocalSearchCompletion]()
    
    override func loadView() {
        super.loadView()
        
        setupTableView()
        createSearch()
    }
    
    func setupTableView() {
        
        locationTableView = UITableView(frame: view.frame, style: .plain)
        locationTableView.backgroundColor = .white
        locationTableView.tableFooterView = UIView(frame: .zero)
        locationTableView.setupToFill(superView: view)
        
        locationTableView.delegate = self
        locationTableView.dataSource = self
    }
    
    func createSearch() {
        searchController.searchBar.placeholder = "Search"
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.tintColor = .white
        searchController.searchBar.barStyle = .black
        definesPresentationContext = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.tintColor = .white
    }
    
}

extension LocationVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResult = searchResults[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle
        return cell
    }
    
}

extension LocationVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let searchResult = searchResults[indexPath.row]
        let searchRequest = MKLocalSearch.Request(completion: searchResult)
        let search = MKLocalSearch(request: searchRequest)
        search.start { [weak self] (response, error) in
            guard let me = self else { return }
            let coordinate = response?.mapItems[0].placemark.coordinate
            if let location = coordinate {
                me.updateUserLocation(location: location)
                me.showToast( message: "Location successfully updated")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    me.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}

extension LocationVC: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let search = searchController.searchBar.text else {
            return
        }
        if let location = currentLocation {
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: location.distance(from: location), longitudinalMeters: location.distance(from: location))
            searchCompleter.region = region
        }
        searchCompleter.queryFragment = search
    }
}

extension LocationVC: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        DispatchQueue.main.async { [weak self] in
            guard let me = self else { return }
            me.locationTableView.reloadData()
        }
    }

}

extension UIView {
    func setupToFill(superView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        superView.addSubview(self)
        leadingAnchor.constraint(equalTo: superView.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superView.trailingAnchor).isActive = true
        topAnchor.constraint(equalTo: superView.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superView.bottomAnchor).isActive = true
    }
}
