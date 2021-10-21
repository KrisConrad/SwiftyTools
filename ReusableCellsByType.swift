//
//  ReusableCellsByType.swift
//
//  Created by Kristopher Conrad on 1/22/21.
//

import UIKit

extension UITableView {
    func register<T: UITableViewCell>(cellWithClass c: T.Type) {
        let className = String(describing: c)
        register(c, forCellReuseIdentifier: className)
    }

    func register<T: UITableViewCell>(cellWithNib c: T.Type) {
        let className = String(describing: c)
        register(UINib(nibName: className, bundle: nil), forCellReuseIdentifier: className)
    }

    func dequeueReusableCell<T: UITableViewCell>(withClass c: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: String(describing: c), for: indexPath) as! T
    }

    func register<T: UITableViewHeaderFooterView>(headerClass c: T.Type) {
        register(c, forHeaderFooterViewReuseIdentifier: String(describing: c))
    }

    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(withClass c: T.Type) -> T {
        return dequeueReusableHeaderFooterView(withIdentifier: String(describing: c)) as! T
    }
}

extension UICollectionView {
    enum SupplementaryViewKind {
        case header
        case footer

        var stringValue: String {
            switch self {
            case .footer: return UICollectionView.elementKindSectionFooter
            case .header: return UICollectionView.elementKindSectionHeader
            }
        }
    }
    func register<T: UICollectionViewCell>(classWithNib c: T.Type) {
        let className = String(describing: c)
        register(UINib(nibName: className, bundle: nil), forCellWithReuseIdentifier: className)
    }

    func dequeueReusableCell<T: UICollectionViewCell>(withClass c: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: String(describing: c), for: indexPath) as! T
    }

    func register<T: UICollectionReusableView>(_ c: T.Type, forSupplementaryViewOfKind kind: UICollectionView.SupplementaryViewKind) {
        register(c, forSupplementaryViewOfKind: kind.stringValue, withReuseIdentifier: String(describing: c))
    }

    func register<T: UICollectionReusableView>(classWithNib c: T.Type, forSupplementaryViewOfKind kind: UICollectionView.SupplementaryViewKind) {
        register(UINib(nibName: String(describing: c), bundle: nil), forSupplementaryViewOfKind: kind.stringValue, withReuseIdentifier: String(describing: c))
    }

    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind kind: String, withClass c: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: c), for: indexPath) as! T
    }
}
