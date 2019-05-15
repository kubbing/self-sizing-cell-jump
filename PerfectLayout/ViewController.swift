//
//  ViewController.swift
//  PerfectLayout
//
//  Created by Jakub Hladik on 14/05/2019.
//  Copyright © 2019 Jakub Hladik. All rights reserved.
//

import UIKit


fileprivate class MyCell: UICollectionViewCell {
    
    weak var titleLabel: UILabel!
    weak var subtitleLabel: UILabel!
    weak var stackView: UIStackView!
    
    var maxWidth: CGFloat? {
        didSet {
            guard let w = maxWidth else {
                maxWidthConstraint?.isActive = false
                return
            }
            
            maxWidthConstraint?.constant = w
            maxWidthConstraint?.isActive = true
        }
    }
    
    var maxWidthConstraint: NSLayoutConstraint? {
        didSet {
            maxWidthConstraint?.isActive = false
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let titleLabel: UILabel = {
            let label = UILabel(frame: .zero)
            label.numberOfLines = 1
            label.adjustsFontSizeToFitWidth = false
            label.lineBreakMode = .byTruncatingTail
            label.font = UIFont.preferredFont(forTextStyle: .headline)
            
            return label
        }()
        
        let subtitleLabel: UILabel = {
            let label = UILabel(frame: .zero)
            label.numberOfLines = 0
            label.font = UIFont.preferredFont(forTextStyle: .body)
            
            return label
        }()
        
        let stackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
            stackView.axis = .vertical
            stackView.distribution = .fill
            stackView.alignment = .leading
            stackView.spacing = 8
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            return stackView
        }()
        
        // contentView autolayout
        
        contentView.backgroundColor = .white
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        let top = contentView.topAnchor.constraint(equalTo: self.topAnchor)
        let left = contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        let bottom = contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        bottom.priority = .defaultHigh // to avoid clash with UIKits's encapsulated-content-height
        let right = contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        
        NSLayoutConstraint.activate([top,
                                     left,
                                     bottom,
                                     right])
        
        // max width using lineView
        
        let lineView = UIView(frame: .zero)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(lineView)
        NSLayoutConstraint.activate([lineView.topAnchor.constraint(equalTo: contentView.topAnchor),
                                     lineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                                     lineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                                     lineView.heightAnchor.constraint(equalToConstant: 1)])
        self.maxWidthConstraint = lineView.widthAnchor.constraint(equalToConstant: 320)
        
        // stackView setup
        
        contentView.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([stackView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
                                     stackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
                                     stackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
                                     stackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)])
        
        // assing properties for later use
        
        self.titleLabel = titleLabel
        self.subtitleLabel = subtitleLabel
        self.stackView = stackView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(withTitle title: String, subtitle: String) {
        
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}


typealias Item = (title: String, subtitle: String)


class ViewController: UIViewController {

    weak var collectionView: UICollectionView!
    
    var data = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.scrollDirection = .vertical
        layout.sectionInset = .zero
        layout.estimatedItemSize = CGSize(width: view.bounds.width, height: 88)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(MyCell.self, forCellWithReuseIdentifier: "\(MyCell.self)")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([collectionView.topAnchor.constraint(equalTo: view.topAnchor),
                                     collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
            self?.addEntries()
        }
        
        self.collectionView = collectionView
    }
    
    func addEntries() {
        
        let begin = data.count
        let end = begin + 20
        var indexPaths = [IndexPath]()
        
        for i in begin..<end {
            indexPaths.append(IndexPath(item: i, section: 0))
            
            let str = "\(i)"
            let element = (str, String(repeating: str, count: i))
            data.append(element)
        }
        
        collectionView.performBatchUpdates({
            collectionView.insertItems(at: indexPaths)
        }) { [weak self] (finished) in
            
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(MyCell.self)",
            for: indexPath) as! MyCell
        
        let payload = data[indexPath.row]
        cell.maxWidth = collectionView.bounds.width
        cell.configure(withTitle: payload.title, subtitle: payload.subtitle)
        
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.row == data.count - 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
                self?.addEntries()
            }
        }
    }
}

extension ViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset)
    }
}
