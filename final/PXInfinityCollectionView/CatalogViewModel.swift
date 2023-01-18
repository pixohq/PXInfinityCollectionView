//
//  CatalogViewModel.swift
//  PXInfinityCollectionView
//
//  Created by Jinwoo Kim on 1/3/23.
//

import UIKit

actor CatalogViewModel {
    let dataSource: UICollectionViewDiffableDataSource<CatalogSectionModel, CatalogItemModel>
    
    init(dataSource: UICollectionViewDiffableDataSource<CatalogSectionModel, CatalogItemModel>) {
        self.dataSource = dataSource
    }
    
    func loadDataSource() async {
        var snapshot: NSDiffableDataSourceSnapshot<CatalogSectionModel, CatalogItemModel> = .init()
        
        snapshot.appendSections([.orthogonal, .list])
        
        snapshot.appendItems(
            [
                .winterImageCopy,
                .springImage,
                .summerImage,
                .fallImage,
                .winterImage,
                .springImageCopy
            ],
            toSection: .orthogonal
        )
        
        snapshot.appendItems(
            [
                .springButton,
                .summerButton,
                .fallButton,
                .winterButton
            ], 
            toSection: .list
        )
        
        if #available(iOS 15.0, *) {
            await dataSource.applySnapshotUsingReloadData(snapshot)
        } else {
            await withCheckedContinuation { continuation in
                dataSource.apply(snapshot, animatingDifferences: false) { 
                    continuation.resume(with: .success(()))
                }
            }
        }
    }
    
    func imageIndexPath(from indexPath: IndexPath) async -> IndexPath? {
        guard let itemModel: CatalogItemModel = await dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }
        
        let imageItemModel: CatalogItemModel
        switch itemModel {
        case .springButton:
            imageItemModel = .springImage
        case .summerButton:
            imageItemModel = .summerImage
        case .fallButton:
            imageItemModel = .fallImage
        case .winterButton:
            imageItemModel = .winterImage
        default:
            return nil
        }
        
        return await dataSource.indexPath(for: imageItemModel)
    }
}
