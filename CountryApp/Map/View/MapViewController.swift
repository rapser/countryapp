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

    /// Span por defecto: cubre bien países pequeños/medianos (ej. Perú, España).
    private static let defaultSpan = MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)

    /// La API no trae área ni bounding box del país (solo el punto central `latlng`), así que
    /// para los países más grandes del mundo —que no entran en `defaultSpan`— usamos un span
    /// calibrado a mano por nombre común (el único identificador disponible en la respuesta).
    private static let largeCountrySpans: [String: MKCoordinateSpan] = [
        "Russia": MKCoordinateSpan(latitudeDelta: 55, longitudeDelta: 130),
        "Canada": MKCoordinateSpan(latitudeDelta: 45, longitudeDelta: 90),
        "United States": MKCoordinateSpan(latitudeDelta: 30, longitudeDelta: 60),
        "China": MKCoordinateSpan(latitudeDelta: 35, longitudeDelta: 60),
        "Brazil": MKCoordinateSpan(latitudeDelta: 38, longitudeDelta: 40),
        "Australia": MKCoordinateSpan(latitudeDelta: 33, longitudeDelta: 41),
        "India": MKCoordinateSpan(latitudeDelta: 29, longitudeDelta: 29),
        "Argentina": MKCoordinateSpan(latitudeDelta: 34, longitudeDelta: 20),
        "Kazakhstan": MKCoordinateSpan(latitudeDelta: 15, longitudeDelta: 41),
        "Algeria": MKCoordinateSpan(latitudeDelta: 18, longitudeDelta: 21),
        "DR Congo": MKCoordinateSpan(latitudeDelta: 18, longitudeDelta: 19),
        "Saudi Arabia": MKCoordinateSpan(latitudeDelta: 16, longitudeDelta: 21),
        "Mexico": MKCoordinateSpan(latitudeDelta: 18, longitudeDelta: 32),
        "Indonesia": MKCoordinateSpan(latitudeDelta: 17, longitudeDelta: 46),
        "Sudan": MKCoordinateSpan(latitudeDelta: 14, longitudeDelta: 18),
        "Libya": MKCoordinateSpan(latitudeDelta: 14, longitudeDelta: 16),
        "Iran": MKCoordinateSpan(latitudeDelta: 15, longitudeDelta: 19),
        "Mongolia": MKCoordinateSpan(latitudeDelta: 11, longitudeDelta: 33),
        "Peru": MKCoordinateSpan(latitudeDelta: 18, longitudeDelta: 13),
        "Chad": MKCoordinateSpan(latitudeDelta: 17, longitudeDelta: 11),
        "Niger": MKCoordinateSpan(latitudeDelta: 13, longitudeDelta: 16),
        "Angola": MKCoordinateSpan(latitudeDelta: 13, longitudeDelta: 13),
        "Mali": MKCoordinateSpan(latitudeDelta: 15, longitudeDelta: 16),
        "South Africa": MKCoordinateSpan(latitudeDelta: 13, longitudeDelta: 17),
        "Colombia": MKCoordinateSpan(latitudeDelta: 17, longitudeDelta: 12)
    ]

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
        let span = Self.largeCountrySpans[countryName] ?? Self.defaultSpan
        mapView.setRegion(MKCoordinateRegion(center: coordinate, span: span), animated: true)
    }
}
