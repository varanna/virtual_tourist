//
//  MapViewController.swift
//  virtual_tourist
//
//  Created by Varosyan, Anna on 03.10.19.
//  Copyright © 2019 Varosyan, Anna. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate  {
    
    //MARK: Constants
    let pinReuseID = "Pin"
    
    
     //MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: Properties
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    //MARK: View overrides
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //needs to be defined for back operation from PhotoView
        setupFetchedResultsController()
        // dispaly pins on map based on fetched data
        displayAllLocations()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupFetchedResultsController()
        // Add LongTapGesture
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(sender:)))
        mapView.addGestureRecognizer(longPressRecognizer)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
           super.viewDidDisappear(animated)
           fetchedResultsController = nil
    }
    
    // MARK: Pins
    // Adds a new pin to the `pins`
    func addPin(longitude: Double, latitude: Double) {
        let pin = Pin(context: dataController.viewContext)
        pin.longitude = longitude
        pin.latitude = latitude
        pin.creationDate = Date()
        try? dataController.viewContext.save()
    }
    
    private func getPinForAnnotation(pinAnnot: MKAnnotation) -> Pin {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        if let fetchedPins = fetchedResultsController.fetchedObjects {
            for itLocPin in fetchedPins {
                if itLocPin.matchAnnotation(pinAnnot) {
                    return itLocPin
                }
            }
        }
        // none of pins match before, create empty pin
        let pin = Pin(context: dataController.viewContext)
        return pin
    }
    
    // MARK: Annotations for pins
    private func displayAllLocations() {
        //remove old annotations from the map
        let oldAnnotations = mapView.annotations
        mapView.removeAnnotations(oldAnnotations)
        //add annotations to map
        mapView.addAnnotations(createMapAnnotationsForAllLocations())
    }

    // Create map annotations based on fetched pin list
    private func createMapAnnotationsForAllLocations() -> [MKPointAnnotation] {
       //create new annotations collection
        var annotations = [MKPointAnnotation]()
        if let fetchedPins = fetchedResultsController.fetchedObjects {
            for itLocPin in fetchedPins {
                annotations.append(itLocPin.createAnnotation())
            }
        }

        return annotations
    }

    // MARK: Fetched Results Controller
    private func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pins")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    
     // MARK: Map actions
     // TODO: add pin by holding on a location on map
     @objc func longPressed(sender: UILongPressGestureRecognizer) {
        if sender.state != .began {
            return
        }
        
        let touchPoint = sender.location(in: mapView)
        let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        addPin(longitude: newCoordinates.longitude, latitude: newCoordinates.latitude)
    }
    
    //MARK: MKMapViewDelegate implementation
    // Create annotation view
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var pinAnnotation = mapView.dequeueReusableAnnotationView(withIdentifier: pinReuseID) as? MKPinAnnotationView
        
        if pinAnnotation != nil {
            pinAnnotation!.annotation = annotation
        }
        else {
            pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinReuseID)
            pinAnnotation!.canShowCallout = true
            pinAnnotation!.pinTintColor = .red
            pinAnnotation!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return pinAnnotation
    }
    
    
    //Open browser to annotation link when user taps annotation
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            mapView.deselectAnnotation(view.annotation! , animated: true)
            let photosListVC = storyboard?.instantiateViewController(withIdentifier: "PhotoListViewController") as! PhotoListViewController;
            
            photosListVC.pin = getPinForAnnotation(pinAnnot: view.annotation!)
            photosListVC.dataController = dataController
            
            navigationController?.pushViewController(photosListVC, animated: true)
        }
    }
}

extension MapViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let pin = anObject as? Pin else {
            preconditionFailure("NOT A PIN!")
        }
        switch type {
        case .insert:
            mapView.addAnnotation(pin.createAnnotation())
            break
        default: ()
        }
    }
}
