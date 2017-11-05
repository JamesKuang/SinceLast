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

// MARK - UITableView

extension UITableViewCell: Reusable {}
extension UITableViewHeaderFooterView: Reusable {}

extension UITableView {
    func register<T: UITableViewCell>(cell cellType: T.Type) {
        self.register(cellType.self, forCellReuseIdentifier: cellType.reuseIdentifier)
    }

    func dequeueCell<T: UITableViewCell>(of cellType: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = self.dequeueReusableCell(withIdentifier: cellType.reuseIdentifier, for:  indexPath) as? T else { fatalError("Unexpected cell reuse identifier") }
        return cell
    }

    func register<T: UITableViewHeaderFooterView>(headerFooter viewType: T.Type) {
        self.register(viewType.self, forHeaderFooterViewReuseIdentifier: viewType.reuseIdentifier)
    }

    func dequeueHeaderFooter<T: UITableViewHeaderFooterView>(of viewType: T.Type) -> T {
        guard let view = self.dequeueReusableHeaderFooterView(withIdentifier: viewType.reuseIdentifier) as? T else { fatalError("Unexpected header/footer reuse identifier") }
        return view
    }
}

// MARK - UICollectionView

extension UICollectionReusableView: Reusable {}

extension UICollectionView {
    func register<T: UICollectionViewCell>(cell cellType: T.Type) {
        self.register(cellType.self, forCellWithReuseIdentifier: cellType.reuseIdentifier)
    }

    func dequeueCell<T: UICollectionViewCell>(of cellType: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else { fatalError("Unexpected cell reuse identifier") }
        return cell
    }

    func register<T: UICollectionReusableView>(view viewType: T.Type, forSupplementaryViewOfKind kind: String) {
        self.register(viewType.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: viewType.reuseIdentifier)
    }

    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(of viewType: T.Type, kind: String, for indexPath: IndexPath) -> T {
        guard let view = self.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: viewType.reuseIdentifier, for: indexPath) as? T else { fatalError("Unexpected reusable supplementary view reuse identifier") }
        return view
    }
}
