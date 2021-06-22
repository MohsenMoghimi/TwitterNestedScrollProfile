//
//  NestedScrollViewController.swift
//  NewNestedScroll
//
//  Created by Saeed on 5/2/21.
//

import UIKit

open class NestedScrollViewController: UIViewController, ScrollViewDelegate {
    private lazy var scrollView = ScrollView(delegate: self)
    public var headerViewController: UIViewController!
    public var headerViewHeight: CGFloat = 200
    public var headerViewOffsetHeight: CGFloat = 50
    public var delegate : NestedScrollViewControllerDelegate?
    private var pagerViewController = PageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    public func setViewControllers(_ viewControllers: [UIViewController]) {
        pagerViewController.orderedViewControllers = viewControllers
        viewControllers.forEach { (vc) in
            var observeView = vc.view
            
//            if let collectionController = vc as? UICollectionViewController {
//                observeView = collectionController.collectionView
//            }
//
//            if let tableViewController = vc as? UITableViewController {
//                observeView = tableViewController.tableView
//            }
            observeView = delegate.observedScrollView
            if let observer = observeView {
                scrollView.addObserverFor(observer)
            }
        }
    }
    
    private func addHeaderViewController() {
        addChild(headerViewController)
        scrollView.contentView.addArrangedSubview(headerViewController.view)
        headerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        headerViewController.view.heightAnchor.constraint(equalToConstant: headerViewHeight).isActive = true
        headerViewController.didMove(toParent: self)
    }
    
    private var pagerHeight: CGFloat {
        guard let window = UIApplication.shared.windows.first else {
            return 0.0
        }
        
        let topPadding = window.safeAreaInsets.top
        let bottomPadding = window.safeAreaInsets.bottom
        
        var offsets = topPadding + bottomPadding + headerViewOffsetHeight
        if navigationController != nil {
            let statusBarHeight = UIApplication.shared.statusBarFrame.height
            offsets += statusBarHeight
        }
        
        return window.bounds.height - offsets
    }
    
    private func addPagerViewController() {
        addChild(pagerViewController)
        scrollView.contentView.addArrangedSubview(pagerViewController.view)
        pagerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pagerViewController.view.heightAnchor.constraint(equalToConstant: pagerHeight).isActive = true
        pagerViewController.didMove(toParent: self)
    }
    
    public override func loadView() {
        super.loadView()
        view.addSubview(scrollView)
        let guide = self.view.safeAreaLayoutGuide
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        addHeaderViewController()
        addPagerViewController()
    }
}

protocol NestedScrollViewControllerDelegate {
    var observedScrollView : UIScrollView {
        set { observedScrollView }
        get { return observedScrollView }
      }
}
