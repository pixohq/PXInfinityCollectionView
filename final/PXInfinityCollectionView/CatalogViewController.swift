//
//  CatalogViewController.swift
//  PXInfinityCollectionView
//
//  Created by Jinwoo Kim on 1/3/23.
//

import UIKit

@MainActor
final class CatalogViewController: UIViewController {
    private var collectionView: UICollectionView!
    private var visualEffectView: UIVisualEffectView!
    private var viewModel: CatalogViewModel!
    private var loadingDataSourceTask: Task<Void, Never>? {
        willSet {
            loadingDataSourceTask?.cancel()
        }
    }
    private var didSelectItemTask: Task<Void, Never>? {
        willSet {
            didSelectItemTask?.cancel()
        }
    }
    
    deinit {
        loadingDataSourceTask?.cancel()
        didSelectItemTask?.cancel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureVisualEffectView()
        configureViewModel()
        
        loadingDataSourceTask = .detached { [weak viewModel, weak collectionView] in
            await viewModel?.loadDataSource()
            await MainActor.run { [weak collectionView] in
                collectionView?.selectItem(at: .init(item: 1, section: .zero), animated: false, scrollPosition: .centeredHorizontally)
            }
        }
    }

    private func configureCollectionView() {
        let collectionViewLayout: CatalogCollectionViewLayout = .init(delegate: self)
        let collectionView: UICollectionView = .init(frame: view.bounds, collectionViewLayout: collectionViewLayout)
        
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        self.collectionView = collectionView
    }
    
    private func configureVisualEffectView() {
        let blurEffect: UIBlurEffect = .init(style: .systemChromeMaterial)
        let visualEffectView: UIVisualEffectView = .init(effect: blurEffect)
        
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(visualEffectView)
        NSLayoutConstraint.activate([
            visualEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            visualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
        
        self.visualEffectView = visualEffectView
    }
    
    private func configureViewModel() {
        let imageCellRegistration: UICollectionView.CellRegistration<UICollectionViewCell, CatalogItemModel> = .init { cell, indexPath, itemIdentifier in
            
            let imageName: String
            
            switch itemIdentifier {
            case .springImage, .springImageCopy:
                imageName = "spring"
            case .summerImage:
                imageName = "summer"
            case .fallImage:
                imageName = "fall"
            case .winterImage, .winterImageCopy:
                imageName = "winter"
            default:
                return
            }
            
            let contentConfiguration: CatalogImageContentConfiguration = .init(imageName: imageName)
            cell.contentConfiguration = contentConfiguration
        }
        
        let plainCellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, CatalogItemModel> = .init { cell, indexPath, itemIdentifier in
            
            let systemImageName: String
            let text: String
            
            switch itemIdentifier {
            case .springButton:
                systemImageName = "sun.min"
                text = "Spring"
            case .summerButton:
                systemImageName = "sun.max"
                text = "Summer"
            case .fallButton:
                systemImageName = "cloud"
                text = "Fall"
            case .winterButton:
                systemImageName = "cloud.snow"
                text = "Winter"
            default:
                return
            }
            
            var contentConfiguration: UIListContentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.image = .init(systemName: systemImageName)
            contentConfiguration.text = text
            contentConfiguration.textProperties.font = .preferredFont(forTextStyle: .largeTitle)
            cell.contentConfiguration = contentConfiguration
        }
        
        let dataSource: UICollectionViewDiffableDataSource<CatalogSectionModel, CatalogItemModel> = .init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .winterImageCopy, .springImage, .summerImage, .fallImage, .winterImage, .springImageCopy:
                return collectionView.dequeueConfiguredReusableCell(using: imageCellRegistration, for: indexPath, item: itemIdentifier)
            case .springButton, .summerButton, .fallButton, .winterButton:
                return collectionView.dequeueConfiguredReusableCell(using: plainCellRegistration, for: indexPath, item: itemIdentifier)
            }
        }
        
        let viewModel: CatalogViewModel = .init(dataSource: dataSource)
        self.viewModel = viewModel
    }
}

extension CatalogViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let itemModel: CatalogItemModel = viewModel.dataSource.itemIdentifier(for: indexPath) else {
            return false
        }
        
        switch itemModel {
        case .springButton, .summerButton, .fallButton, .winterButton:
            return true
        default:
            return false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectItemTask = .detached { [weak viewModel, weak collectionView] in
            guard 
                let imageIndexPath: IndexPath = await viewModel?.imageIndexPath(from: indexPath),
                !Task.isCancelled
            else {
                return
            }
            
            await MainActor.run { [weak collectionView] in
                collectionView?.deselectItem(at: indexPath, animated: true)
                collectionView?.scrollToItem(at: imageIndexPath, at: .centeredHorizontally, animated: true)
            }
        }
    }
}

extension CatalogViewController: CatalogCollectionViewLayoutDelegate {
    func catalogCollectionViewLayoutSectionModel(for sectionIndex: Int) -> CatalogSectionModel? {
        if #available(iOS 15.0, *) {
            return viewModel.dataSource.sectionIdentifier(for: sectionIndex)
        } else {
            return viewModel.dataSource.snapshot().sectionIdentifiers[sectionIndex]
        }
    }
}
