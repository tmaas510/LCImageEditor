//
//  LCEffectMenu.swift
//  LCImageEditor
//
//  Created by LuckyClub on 12/15/20.
//  Copyright © 2020 LuckyClub. All rights reserved.
//

import UIKit

class LCEffectMenu: UIView {

   private let collectionView: UICollectionView
   private var availableEffectors: [LCEffectable]
   private var demoImages: [String:UIImage] = [:]
   private var selectedCellIndex: Int = 0
   private var isObservingCollectionView = true
   
   public var didSelectEffector: (LCEffectable) -> Void = { _ in }
   
   public var image: UIImage {
       didSet {
           demoImages.removeAll()
           collectionView.reloadData()
       }
   }
   
   init(withImage image: UIImage, availableFilters: [LCEffectable]) {
       self.image = image
       
       let layout = UICollectionViewFlowLayout()
       layout.itemSize = CGSize(width: 52, height: 64)
       layout.minimumLineSpacing = 0
       layout.scrollDirection = .horizontal
       collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
       self.availableEffectors = availableFilters.count == 0 ? kDefaultEffectors : availableFilters
       
       super.init(frame: .zero)
              
       self.addSubview(collectionView)
       collectionView.translatesAutoresizingMaskIntoConstraints = false
       collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
       collectionView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
       collectionView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
       collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
       
       collectionView.register(LCFilterCell.classForCoder(), forCellWithReuseIdentifier: LCFilterCell.reussId)
       
       collectionView.backgroundColor = .white
       collectionView.dataSource = self
       collectionView.delegate = self
       collectionView.showsHorizontalScrollIndicator = false
       collectionView.contentInset = UIEdgeInsets(top: 0,left: 14,bottom: 0,right: 14)
       
       collectionView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.old, context: nil)
       isObservingCollectionView = true
       
       self.backgroundColor = .clear
       collectionView.backgroundColor = .clear
   }
   
   func insert(toView parenetView: UIView) {
       parenetView.addSubview(self)
       
       translatesAutoresizingMaskIntoConstraints = false
       heightAnchor.constraint(equalToConstant: 64).isActive = true
       rightAnchor.constraint(equalTo: parenetView.rightAnchor).isActive = true
       leftAnchor.constraint(equalTo: parenetView.leftAnchor).isActive = true
       bottomAnchor.constraint(equalTo: parenetView.bottomAnchor).isActive = true
   }
   
   override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
       if let observedObject = object as? UICollectionView, observedObject == collectionView {
           collectionView.removeObserver(self, forKeyPath: "contentSize")
           isObservingCollectionView = false
           
           collectionView.scrollToItem(at: IndexPath(row: self.selectedCellIndex, section: 0), at: .centeredHorizontally, animated: false)
       }
   }
   
   required init?(coder aDecoder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
   }
   
   deinit {
       if isObservingCollectionView {
           collectionView.removeObserver(self, forKeyPath: "contentSize")
       }
   }

}

extension LCEffectMenu: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return availableEffectors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LCFilterCell.reussId, for: indexPath) as? LCFilterCell
            else { return UICollectionViewCell() }
        
        let effector = availableEffectors[indexPath.item]
        if let demo = demoImages[effector.effectorName()] {
           cell.imageView.image = demo
        } else {
            let demo = effector.effector(image: image)
            demoImages[effector.effectorName()] = demo
            cell.imageView.image = demo
        }
        
        cell.name.text = effector.effectorName()
        if indexPath.item == selectedCellIndex {
            cell.setSelected()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let effector = availableEffectors[indexPath.item]
        
        let prevSelectedCellIndex = selectedCellIndex
        
        selectedCellIndex = indexPath.item
        (collectionView.cellForItem(at: IndexPath(row: selectedCellIndex, section: 0)) as? LCFilterCell)?.setSelected()
        
        collectionView.reloadItems(at: [IndexPath(row: prevSelectedCellIndex, section: 0)])
        
        didSelectEffector(effector)
    }
    
}
