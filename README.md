# Camera Filter
Aplicativbo de camera com filtros de fotos


## Motivação
Fortalecer conhecimentos em [RxSwift](https://github.com/ReactiveX/RxSwif)


- Feature
- Criei um observable para compartilhar as imagens entre as views
- Consigo receber essa imagem atravesses do subscribe em outra tela usando o conceito de prepare for segue
- PHImageManager ele cria uma cópia com duas vertentes das imagens, abaixo crie uma lógica para ignorar imagens de baixa qualidade


```swift
//FilterCollectionViewController

var subjectImage = PublishSubject<UIImage>()
var observable: Observable<UIImage> {
		return subjectImage.asObservable()
}
	
override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
	let selectedAsset = collectionAssets[indexPath.row]
		
		PHImageManager.default().requestImage(for: selectedAsset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFill, options: nil) { image, info in
			
			guard let info = info else {return}
			
			let isDegradedImage = info["PHImageResultIsDegradedKey"] as! Bool
			
			if !isDegradedImage {
				
				if let image = image {
					self.subjectImage.onNext(image)
					self.dismiss(animated: true, completion: nil)
				}
				
			}
			
		}
		
}


//CameraFilterController
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		//sao duas view controller por isso foi feito dessa maneira
		guard let vc = segue.destination as? UINavigationController,
					let destination = vc.viewControllers.first as? FilterCollectionViewController else {fatalError("dont existe route")}
		
		destination.observable.subscribe(onNext: { image in
			
			
			self.updateUi(image)
			
			//self.imgContainer.image = image
			
		}).disposed(by: disposedBag)
		
}

	
```

##
- Criei  lógica de observable também para aplicar os filtros nas imagens


```swift
//FilterService  
func applyFilter(_ inputImage: UIImage) -> Observable<UIImage> {
		
		return Observable.create {observer  in
			
			self.applyFilter(inputImage) {imageFiltered in
				
				observer.onNext(imageFiltered)
				
			}
			return Disposables.create()
			
		}
		
}
	
	
private func applyFilter(_ inputImage: UIImage,_ completion: @escaping (UIImage)->Void) {
		guard let filter = CIFilter(name: "CICMYKHalftone") else {return}
		filter.setValue(0.5, forKey: kCIInputWidthKey)
		
		if let sourceImage = CIImage(image: inputImage) {
			filter.setValue(sourceImage, forKey: kCIInputImageKey)
			
			if let ciImage = self.ciContext.createCGImage(filter.outputImage!, from: filter.outputImage!.extent) {
				
				let imageProcesed = UIImage(cgImage: ciImage, scale: inputImage.scale, orientation: inputImage.imageOrientation)
				completion(imageProcesed)
				
			}
			
		}
	}
	
//CameraFitlerViewController
@IBAction func handlePressFilter(_ sender: UIButton) {
		
		guard let sourceImage = self.imgContainer.image else {return}
		
		FilterService().applyFilter(sourceImage).subscribe(onNext:{ filterImage in
			
			DispatchQueue.main.async {
				self.imgContainer.image = filterImage
			}
			
		}).disposed(by: disposedBag)
}

```







