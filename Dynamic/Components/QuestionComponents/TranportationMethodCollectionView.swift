//
//  TranportationMethodCollectionView.swift
//  Dynamic
//
//  Created by Brandon Baker on 5/2/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import MapKit

class TranportationTypeCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource {

    var transportTypes : [MKDirectionsTransportType] = [.automobile, .walking]
    
    init() {
        
        let maxSize = (UIScreen.main.bounds.width / 2) - 64
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: maxSize, height: maxSize)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 24
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        
        super.init(frame: .zero, collectionViewLayout: layout)
        self.setCollectionViewLayout(layout, animated: true)
        self.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        self.dataSource = self
        self.delegate = self
        self.backgroundColor = .clear
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return transportTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.contentView.backgroundColor = .green
        return cell
    }
    
}
