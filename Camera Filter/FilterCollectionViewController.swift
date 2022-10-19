//
//  FilterCollectionViewController.swift
//  Camera Filter
//
//  Created by kenjimaeda on 18/10/22.
//

import UIKit
import Photos

private let reuseIdentifier = "Cell"

class FilterCollectionViewController: UICollectionViewController {
	
	var collectionAssets = [PHAsset]()
	
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
	
	/*
	 // MARK: - Navigation
	 
	 // In a storyboard-based application, you will often want to do a little preparation before navigation
	 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	 // Get the new view controller using [segue destinationViewController].
	 // Pass the selected object to the new view controller.
	 }
	 */
	
	// MARK: UICollectionViewDataSource
	
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return collectionAssets.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard	let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? PhotosCollectionViewCell  else { fatalError("PhotosCollectionViewCell dont existe") }
		
		let asset = collectionAssets[indexPath.row]
		let manager = PHImageManager()
		
		//assincrono request por isso dispatchQueue
		//estou fazendo a requisicao de cada foto e colocando na img photo
		manager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFit, options: nil) { image, _ in
			
			DispatchQueue.main.async {
				cell.imgPhoto.image = image
			}
		}
		
		return cell
	}
	
	// MARK: UICollectionViewDelegate
	
	/*
	 // Uncomment this method to specify if the specified item should be highlighted during tracking
	 override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
	 return true
	 }
	 */
	
	/*
	 // Uncomment this method to specify if the specified item should be selected
	 override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
	 return true
	 }
	 */
	
	/*
	 // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
	 override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
	 return false
	 }
	 
	 override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
	 return false
	 }
	 
	 override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
	 
	 }
	 */
	
}
