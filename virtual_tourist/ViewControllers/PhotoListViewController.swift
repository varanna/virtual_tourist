//
//  PhotoListViewController.swift
//  virtual_tourist
//
//  Created by Varosyan, Anna on 07.10.19.
//  Copyright © 2019 Varosyan, Anna. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit
import Kingfisher


class PhotoListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, NSFetchedResultsControllerDelegate, MKMapViewDelegate {
   
    //MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    @IBOutlet weak var newCollection: UIButton!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    // MARK: Private properties
    private let reuseId = "PhotoCell"
    private let itemsPerRow: CGFloat = 2
    private let insets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    
    // MARK: Public properties
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var pin: Pin!
       
    //MARK: View overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        // collection view delegates to self
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        photoCollectionView.allowsSelection = true
        photoCollectionView.isUserInteractionEnabled = true
        // get photos for pin and show
        setupFetchedResultsController()
        mapView.delegate = self
        getPhotosForPin()
        setMapAnnotationForPin()
       }
       
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        setupFetchedResultsController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
       super.viewDidDisappear(animated)
       fetchedResultsController = nil
    }
    
    // MARK: Fetch results controller related functions
    // Check if there are no stored photos, get from Flickr
    private func getPhotosForPin() {
        if (fetchedResultsController.sections?[0].numberOfObjects ?? 0 == 0) {
            enableNewCollection(false)
            getPhotos()
            enableNewCollection(true)
        }
    }
   
    // Setup fetched results controller for the corresponding pin based on photos cache
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(pin!.creationDate!)-photos")
        fetchedResultsController.delegate = self
        queryPhotosViaFetchedResultsController()
        
    }
    
    // Perform fetch request for getting photos
    private func queryPhotosViaFetchedResultsController() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    // MARK: Map functions
    // Show map annotation for map
    private func setMapAnnotationForPin() {
        let annotPin = pin.createAnnotation()
        mapView.addAnnotation(annotPin)
        mapView.showAnnotations([annotPin], animated: true)
        mapView.isUserInteractionEnabled = false
    }
    
    // MARK: Photo functions
    func addPhoto(url: String) {
        let photo = Photo(context: dataController.viewContext)
        photo.creationDate = Date()
        photo.url = url
        photo.pin = pin
        try? dataController.viewContext.save()
    }
    
    func deletePhoto(_ photo: Photo) {
        dataController.viewContext.delete(photo)
        do {
            try dataController.viewContext.save()
        } catch {
            print("Error saving")
        }
        
    }
    // Getting photos via Flickr
    private func getPhotos() {
        FlickrAPI.getListOfPhotosIn(lat: pin.latitude, lon: pin.longitude) { (error, photosURL) in
            // if photos is empty show empty background
            switch error {
            case .notConnected:
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Hmmmm..", message:
                        "There seems to be no internet connection! please, connect to a network then try again.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                    self.present(alertController, animated: true, completion: nil)
                }
                break
            case .connected:
                for photoURL in photosURL! {
                    self.addPhoto(url: photoURL)
                }
                self.queryPhotosViaFetchedResultsController()
                break
            case .other:
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Hmmmm..", message:
                        "Something bad occured. Please, try again.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
                    self.present(alertController, animated: true, completion: nil)
                }
                break
            }
            
            DispatchQueue.main.async {
                self.photoCollectionView.reloadData()
            }
        }
    }
    
    // MARK: New Collection
    // IBAction fo new collection functionality
    @IBAction func performNewCollection(_ sender: Any) {
        refreshAllPhotos()
    }
    
    // enable/disable possibilty of creating new collection
    private func enableNewCollection(_ en: Bool) {
        newCollection.isEnabled = en
    }
    
    // checks if there are already photose, removes and gets new photos
    private func refreshAllPhotos() {
       if let photos = fetchedResultsController.fetchedObjects {
           for photo in photos {
               dataController.viewContext.delete(photo)
               do {
                   try dataController.viewContext.save()
               } catch {
                   print("Error saving of photo removal.")
               }
           }
       }
      getPhotos()
   }
    
    // MARK:  Delegate UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = insets.right * (itemsPerRow + 1)
        let availableWidth = view.frame.width - padding
        let widthOfItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthOfItem, height: widthOfItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return insets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return insets.right
    }
    
    // MARK :  Delegate UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numOfPhotos = fetchedResultsController.sections?[section].numberOfObjects
        if (numOfPhotos ?? 0 == 0) {
           setEmptyInfo("No photos available. Try to refresh.")
        } else {
           removeEmptyInfo()
        }
        return numOfPhotos ?? 0
    }
    
       
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let oPhoto = fetchedResultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as! PhotoCell
           
        // Configure cell
        if let photoData = oPhoto.data {
            cell.imageView.image = UIImage(data: photoData)
        } else if let photoURL = oPhoto.url {
            guard let url = URL(string: photoURL) else {
                print("The URL is wrong or not available for the photo!")
                return cell
            }
        
             cell.imageView.kf.setImage(with: url, placeholder: UIImage(named: "Placeholder"), options: nil, progressBlock: nil) { result in
                    switch result {
                    case .success(let value):
                        print("Image: \(value.image). Got from: \(value.cacheType)")
                        oPhoto.data = value.image.pngData()
                        try? self.dataController.viewContext.save()
                        break
                    case .failure(let error):
                        print("Error: \(error)")
                        break
                    }
            }
        }

        return cell
    }
    
    //MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        deletePhoto(photoToDelete)
    }
    
    

    private func setEmptyInfo(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: photoCollectionView.bounds.size.width, height: photoCollectionView.bounds.size.height))
        messageLabel.text = message
        messageLabel.textAlignment = .center;
        messageLabel.sizeToFit()
        
        photoCollectionView.backgroundView = messageLabel;
    }
    private func removeEmptyInfo() {
        photoCollectionView.backgroundView = nil
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            photoCollectionView.insertItems(at: [newIndexPath!])
            break
        case .delete:
            photoCollectionView.deleteItems(at: [indexPath!])
            break
        default: ()
        }
    }
    //MARK: MKMapViewDelegate implementation
    // Create annotation view
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var pinAnnotation = mapView.dequeueReusableAnnotationView(withIdentifier: "Pin") as? MKPinAnnotationView
        
        if pinAnnotation != nil {
            pinAnnotation!.annotation = annotation
        }
        else {
            pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            pinAnnotation!.canShowCallout = true
            pinAnnotation!.pinTintColor = .red
            pinAnnotation!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return pinAnnotation
    }
}
