//
//  MapViewController.swift
//  CountryApp
//
//  Created by miguel tomairo on 16/01/25.
//

import Foundation
import UIKit
import MapKit

protocol MapViewProtocol: AnyObject {
    func showLocation(latitude: Double, longitude: Double, countryName: String)
}

class MapViewController: UIViewController, MapViewProtocol {
    var presenter: MapPresenterProtocol?
    private let mapView = MKMapView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        presenter?.viewDidLoad()
    }

    private func setupMapView() {
        view.backgroundColor = .white
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)

        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func showLocation(latitude: Double, longitude: Double, countryName: String) {
        title = countryName
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = countryName

        mapView.addAnnotation(annotation)
        mapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)), animated: true)
    }
}
