//
//  FilterService.swift
//  Camera Filter
//
//  Created by kenjimaeda on 20/10/22.
//

import Foundation
import CoreImage
import UIKit
import RxSwift


struct FilterService {
	
	var ciContext: CIContext
	
	init()  {
		self.ciContext = CIContext()
	}
	
	func applyFilter(_ inputImage: UIImage) -> Observable<UIImage> {
		
		return  Observable.create { observer in
			
			self.applyFilter(inputImage) { imageFiltered in
				observer.onNext(imageFiltered)
			}
			
			return Disposables.create()
			
		}
		
	}
	
	
	private func applyFilter(_ inputImage: UIImage,_ completion: @escaping (UIImage)->Void) {
		guard  let filter = CIFilter(name: "CICMYKHalftone") else {return}
		filter.setValue(0.5, forKey: kCIInputWidthKey)
		
		if let sourceImage = CIImage(image: inputImage) {
			filter.setValue(sourceImage, forKey: kCIInputImageKey)
			
			if let ciImg = self.ciContext.createCGImage(filter.outputImage!, from: filter.outputImage!.extent) {
				
				let processedImage = UIImage(cgImage: ciImg, scale: inputImage.scale, orientation: inputImage.imageOrientation)
				completion(processedImage)
				
			}
			
		}
		
		
	}
	
}
