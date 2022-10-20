//
//  ViewController.swift
//  Camera Filter
//
//  Created by kenjimaeda on 18/10/22.
//

import UIKit
import RxSwift

class CameraFilterViewController: UIViewController {
	
	@IBOutlet weak var buttonApplyFilter: UIButton!
	@IBOutlet weak var imgContainer: UIImageView!
	
	
	var disposedBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.navigationController?.navigationBar.prefersLargeTitles = true
	}
	
	@IBAction func handlePressFilter(_ sender: UIButton) {
		
		guard let sourceImage = self.imgContainer.image else {return}
		
		FilterService().applyFilter(sourceImage).subscribe(onNext:{ filterImage in
			
			DispatchQueue.main.async {
				self.imgContainer.image = filterImage
			}
			
		}).disposed(by: disposedBag)
	}
	
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		//sao duas view controller por isso foi feito dessa maneira
		guard let vc = segue.destination as? UINavigationController,
					let destination = vc.viewControllers.first as? FilterCollectionViewController else {fatalError("dont existe route")}
		
		destination.observable.subscribe(onNext: { image in
			
			self.updateUi(image)
			
			//self.imgContainer.image = image
			
		}).disposed(by: disposedBag)
		
	}
	
	func updateUi(_ image: UIImage) {
		
		imgContainer.image = image
		buttonApplyFilter.isHidden = false
		
	}
	
}
