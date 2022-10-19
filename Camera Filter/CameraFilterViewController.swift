//
//  ViewController.swift
//  Camera Filter
//
//  Created by kenjimaeda on 18/10/22.
//

import UIKit
import RxSwift

class CameraFilterViewController: UIViewController {
	
	@IBOutlet weak var imgContainer: UIImageView!
	var disposedBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.navigationController?.navigationBar.prefersLargeTitles = true
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		//sao duas view controller por isso foi feito dessa maneira
		guard let vc = segue.destination as? UINavigationController,
					let destination = vc.viewControllers.first as? FilterCollectionViewController else {fatalError("Cant acesses route")}
		
		destination.obersableImage.subscribe(onNext: { [weak self] image in
		     
			self?.imgContainer.image = image
	 
		}).disposed(by: disposedBag)
}
}
