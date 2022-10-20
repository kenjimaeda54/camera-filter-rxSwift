//
//  FilterCollectionViewController.swift
//  Camera Filter
//
//  Created by kenjimaeda on 18/10/22.
//

import UIKit
import Photos
import RxSwift

private let reuseIdentifier = "Cell"

class FilterCollectionViewController: UICollectionViewController {
	
	var collectionAssets = [PHAsset]()
	var subjectImage = PublishSubject<UIImage>()
	var observable: Observable<UIImage> {
		return subjectImage.asObservable()
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		populatePhotos()
		
		
		self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
		
	}
	
	func populatePhotos(){
		//weak self e para garantir qeu nao ocorra memoria leak pois
		//fetchAssets e assincrono
		PHPhotoLibrary.requestAuthorization {[weak self] (status) in
			
			if status == .authorized  {
				let assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
				
				assets.enumerateObjects { (object, inbdex, stop) in
					self?.collectionAssets.append(object)
					
				}
				
				//mais recentes em primerio
				self?.collectionAssets.reverse()
				
				DispatchQueue.main.async {
					self?.collectionView.reloadData()
					
				}
				
			}
			
		}
	}
	
	
	
	// MARK: UICollectionViewDataSource
	
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return collectionAssets.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard	let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? PhotosCollectionViewCell else {
			fatalError("PhotosCollectionViewCell dont exists")
		}
		let asset = collectionAssets[indexPath.row]
		let manager = PHImageManager()
		
		//assincrono request por isso dispatchQueue
		//estou fazendo a requisicao de cada foto e colocando na img photo
		manager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: nil) { image, _ in
			
			DispatchQueue.main.async {
				cell.imgPhoto.image = image
			}
			
		}
		return cell
	}
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let selectedAsset = collectionAssets[indexPath.row]
		
		PHImageManager.default().requestImage(for: selectedAsset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFill, options: nil) { image, info in
			
			guard let info = info else {return}
			
			// pode retornar uma image com baixa qualidade
			let isDegradedImage = info["PHImageResultIsDegradedKey"] as! Bool
			
			if !isDegradedImage {
				
				if let image = image {
					self.subjectImage.onNext(image)
					self.dismiss(animated: true, completion: nil)
				}
				
			}
			
		}
		
	}
}

