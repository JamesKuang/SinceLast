//
//  Reusable.swift
//  SinceLast
//
//  Created by James Kuang on 5/22/17.
//  Copyright © 2017 Incyc. All rights reserved.
//

import UIKit

protocol Reusable: class {
    static var reuseIdentifier: String { get }
}

extension Reusable {
    static var reuseIdentifier: String { return String(describing: Self.self) }
}

extension UICollectionReusableView: Reusable {}

extension UICollectionView {
    func register<T: UICollectionViewCell>(cell cellType: T.Type) where T: Reusable {
        self.register(cellType.self, forCellWithReuseIdentifier: cellType.reuseIdentifier)
    }

    func dequeueCell<T: UICollectionViewCell>(of cellType: T.Type, for indexPath: IndexPath) -> T where T: Reusable {
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else { fatalError("Unexpected cell reuse identifier") }
        return cell
    }

    func register<T: UICollectionReusableView>(view viewType: T.Type, forSupplementaryViewOfKind kind: String) where T: Reusable {
        self.register(viewType.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: viewType.reuseIdentifier)
    }

    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(of viewType: T.Type, kind: String, for indexPath: IndexPath) -> T where T: Reusable {
        guard let view = self.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: viewType.reuseIdentifier, for: indexPath) as? T else { fatalError("Unexpected reusable supplementary view reuse identifier") }
        return view
    }
}
