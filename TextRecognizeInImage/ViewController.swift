//
//  ViewController.swift
//  TextRecognizeInImage
//
//  Created by Sachin Dumal on 03/12/19.
//  Copyright © 2019 Sachin Dumal. All rights reserved.
//

import UIKit
import Vision
import VisionKit

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var textView: UITextView!
    var request = VNRecognizeTextRequest()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupImage()
    }
    
 
    
    @IBAction func touchupInsideCamera(_ sender: Any) {
        setupActionSheet()
    }
    
    
    private func scanDocument() {
        let documentVC = VNDocumentCameraViewController()
        documentVC.delegate = self
        self.present(documentVC, animated: true, completion: nil)
    }
    
    private func setupActionSheet(){
        
        let actionSheet = UIAlertController(title: "Choose Option", message: "", preferredStyle: .actionSheet)
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { (alertAction) in
            self.setupGallery()
        }
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (alertAction) in
            //self.setupCamera()
            self.scanDocument()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(galleryAction)
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    private func setupCamera(){
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imageCameraPicker = UIImagePickerController()
            imageCameraPicker.delegate = self
            imageCameraPicker.sourceType = .camera
            imageCameraPicker.allowsEditing = false
            self.present(imageCameraPicker, animated: true, completion: nil)
        }
    }
    
    private func setupGallery(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePhotoLibraryPicker = UIImagePickerController()
            imagePhotoLibraryPicker.delegate = self
            imagePhotoLibraryPicker.allowsEditing = false
            imagePhotoLibraryPicker.sourceType = .photoLibrary
            self.present(imagePhotoLibraryPicker, animated: true, completion: nil)
        }
    }
    
    private func setupImage(){
        self.imageView.image = UIImage(named: "image.jpg")
        setupVisionTextRecognizeImage(image:self.imageView.image)

    }

    private func setupVisionTextRecognizeImage(image: UIImage?){

        var textString = ""

         request = VNRecognizeTextRequest{ request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {fatalError("Recieved invalid observations")}
            for observation in observations {
                guard let bestCandidate  = observation.topCandidates(1).first else {
                    print("No candidate")
                    continue
                }
                print("\(bestCandidate.string)")
                
                textString += " \n\(bestCandidate.string)"
                
                DispatchQueue.main.async {
                    self.textView.text = textString
                }

            }}
        
               request.recognitionLevel = .fast
               request.recognitionLanguages = ["en_US"]
               let requests = [request]
               DispatchQueue.global(qos: .userInitiated).async {
                guard let img = image?.cgImage else {
                       fatalError("Missing image to scan")}
                   let handle = VNImageRequestHandler(cgImage: img, options: [:])
                   try? handle.perform(requests)}}

}

// MARK:- EXTENSION VNDOCUMENTCAMERAVIEWCONTROLLER

extension ViewController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        for i in 0..<scan.pageCount {
            let img = scan.imageOfPage(at: i)
            //self.saveImage(image:img)
            self.imageView.image = img
            self.setupVisionTextRecognizeImage(image: self.imageView.image)
        }
    }
    
    private func saveImage(image:UIImage) {
        let alertController = UIAlertController(title: "SAVE", message: "do you want to save image?", preferredStyle: .alert)
        let sAlert = UIAlertAction(title: "YES", style: .default) { (action) in
            self.imageView.image = image
            self.setupVisionTextRecognizeImage(image: self.imageView.image)
        }
        
        let noAlert = UIAlertAction(title: "NO", style: .default) { (action) in
            
        }
        
        alertController.addAction(sAlert)
        alertController.addAction(noAlert)
        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK:- EXTENSION UIImagePickerController

extension ViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        self.imageView.image = image
        setupVisionTextRecognizeImage(image: self.imageView.image)
    }
}

