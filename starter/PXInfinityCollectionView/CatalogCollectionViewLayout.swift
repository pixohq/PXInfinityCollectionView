//
//  CatalogCollectionViewLayout.swift
//  PXInfinityCollectionView
//
//  Created by Jinwoo Kim on 1/3/23.
//

import UIKit

@MainActor protocol CatalogCollectionViewLayoutDelegate: AnyObject {
    func catalogCollectionViewLayoutSectionModel(for sectionIndex: Int) -> CatalogSectionModel?
}

@MainActor
final class CatalogCollectionViewLayout: UICollectionViewCompositionalLayout {
    convenience init(delegate: CatalogCollectionViewLayoutDelegate) {
        let configuration: UICollectionViewCompositionalLayoutConfiguration = .init()
        configuration.scrollDirection = .vertical
        
        self.init(
            sectionProvider: { [weak delegate] sectionIndex, environment in
                guard let sectionModel: CatalogSectionModel = delegate?.catalogCollectionViewLayoutSectionModel(for: sectionIndex) else {
                    return nil
                }
                
                switch sectionModel {
                case .orthogonal:
                    let itemSize: NSCollectionLayoutSize = .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                    let item: NSCollectionLayoutItem = .init(layoutSize: itemSize)
                    
                    let groupSize: NSCollectionLayoutSize = .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(9.0 / 16.0))
                    
                    let group: NSCollectionLayoutGroup
                    if #available(iOS 16.0, *) {
                        group = .horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
                    } else {
                        group = .horizontal(layoutSize: groupSize, subitem: item, count: 1)
                    }
                    
                    let section: NSCollectionLayoutSection = .init(group: group)
                    section.contentInsetsReference = .none
                    section.orthogonalScrollingBehavior = .paging
                    
                    return section
                case .list:
                    let listConfiguration: UICollectionLayoutListConfiguration = .init(appearance: .insetGrouped)
                    let section: NSCollectionLayoutSection = .list(using: listConfiguration, layoutEnvironment: environment)
                    
                    return section
                }
            },
            configuration: configuration
        )
    }
}
