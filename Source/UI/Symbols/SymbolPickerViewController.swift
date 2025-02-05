// Copyright © 2018-2025 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

final class SymbolPickerViewController: UICollectionViewController, UISearchBarDelegate {

    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = Strings.Contacts.searchPlaceholder
        controller.searchBar.delegate = self
        return controller
    }()

    private lazy var allSymbols: [String] = {
        guard let bundle = Bundle(identifier: "com.apple.CoreGlyphs"),
        let resourcesURL = bundle.url(forResource: "name_availability", withExtension: "plist"),
        let dictionary = NSDictionary(contentsOf: resourcesURL),
        let symbolsDictionary = dictionary["symbols"] as? [String : String] else {
            return []
        }
        return Array(symbolsDictionary.keys).sorted(by: <)
    }()

    private lazy var symbols = allSymbols {
        didSet {
            collectionView.reloadData()
        }
    }

    var onSymbolSelected: ((String) -> Void)?

    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Pick an icon"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        collectionView.backgroundColor = .systemBackground
        collectionView.registerReusableCell(SymbolCell.self)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        symbols.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(SymbolCell.self, for: indexPath)
        cell.symbol = symbols[indexPath.item]
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSymbolSelected?(symbols[indexPath.item])
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        symbols = allSymbols.filter({ $0.contains(searchText.lowercased()) })
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        symbols = allSymbols
    }

    private final class SymbolCell: UICollectionViewCell {

        private lazy var imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.tintColor = .label
            return imageView
        }()

        var symbol: String? {
            didSet {
                imageView.image = if let symbol {
                    .init(systemName: symbol, withConfiguration: UIImage.SymbolConfiguration(scale: .large))
                } else {
                    nil
                }
            }
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setup()
        }

        private func setup() {
            contentView.addSubview(imageView)
            NSLayoutConstraint.activate([
                imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
        }

        override func prepareForReuse() {
            super.prepareForReuse()

            symbol = nil
        }
    }
}
