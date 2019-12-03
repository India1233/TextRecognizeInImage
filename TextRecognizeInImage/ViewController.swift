//
//  ViewController.swift
//  TextRecognizeInImage
//
//  Created by Sachin Dumal on 03/12/19.
//  Copyright © 2019 Sachin Dumal. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var textView: UITextView!
    var request = VNRecognizeTextRequest()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupImage()
       setupVisionTextRecognizeImage()
    }
    
 
    
    @IBAction func touchupInsideCamera(_ sender: Any) {
        setupActionSheet()
    }
    
    private func setupActionSheet(){
        
        let actionSheet = UIAlertController(title: "Choose Option", message: "", preferredStyle: .actionSheet)
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { (alertAction) in
            self.setupGallery()
        }
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (alertAction) in
            self.setupCamera()
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
    }

    private func setupVisionTextRecognizeImage(){

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
                   guard let img = UIImage(named: "image.jpg")?.cgImage else {
                       fatalError("Missing image to scan")}
                   let handle = VNImageRequestHandler(cgImage: img, options: [:])
                   try? handle.perform(requests)}}

}


// MARK:- EXTENSION UIImagePickerController

extension ViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        self.imageView.image = image
        setupVisionTextRecognizeImage()
    }
}

