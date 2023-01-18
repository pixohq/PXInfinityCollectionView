//
//  CatalogImageContentView.swift
//  PXInfinityCollectionView
//
//  Created by Jinwoo Kim on 1/3/23.
//

import UIKit

@MainActor
final class CatalogImageContentView: UIView {
    private var imageView: UIImageView!
    private var _configuration: CatalogImageContentConfiguration!
    private var loadingImageTask: Task<Void, Error>? {
        willSet {
            loadingImageTask?.cancel()
        }
    }
    
    convenience init(configuration: CatalogImageContentConfiguration) {
        self.init(frame: .null)
        configureImageView()
        self.configuration = configuration
    }
    
    deinit {
        loadingImageTask?.cancel()
    }
    
    private func configureImageView() {
        let imageView: UIImageView = .init(frame: bounds)
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        self.imageView = imageView
    }
}

extension CatalogImageContentView: UIContentView {
    var configuration: UIContentConfiguration {
        get {
            return _configuration
        }
        set {
            let oldConfiguration: CatalogImageContentConfiguration? = _configuration
            let newConfiguration: CatalogImageContentConfiguration = newValue as! CatalogImageContentConfiguration
            
            guard oldConfiguration != newConfiguration else {
                return
            }
            
            _configuration = newConfiguration
            
            imageView.image = nil
            loadingImageTask = .detached { [_configuration, weak imageView] in
                guard 
                    let imageName: String = _configuration?.imageName,
                    let image: UIImage = .init(named: imageName),
                    !Task.isCancelled
                else {
                    return
                }
                
                await MainActor.run { [weak imageView] in
                    imageView?.image = image
                }
            }
        }
    }
    
    func supports(_ configuration: UIContentConfiguration) -> Bool {
        configuration is CatalogImageContentConfiguration
    }
}
