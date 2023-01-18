//
//  CatalogImageContentConfiguration.swift
//  PXInfinityCollectionView
//
//  Created by Jinwoo Kim on 1/3/23.
//

import UIKit

@MainActor
struct CatalogImageContentConfiguration: UIContentConfiguration {
    let imageName: String
    
    func makeContentView() -> UIView & UIContentView {
        CatalogImageContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> CatalogImageContentConfiguration {
        self
    }
}

extension CatalogImageContentConfiguration: Equatable {
    static func == (lhs: CatalogImageContentConfiguration, rhs: CatalogImageContentConfiguration) -> Bool {
        lhs.imageName == rhs.imageName
    }
}
