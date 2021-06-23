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
    public var delegate : NestedScrollViewControllerDelegate? {
        didSet {
            addObserverForScrollViews()
        }
    }
    public var segmentController: UISegmentedControl! {
        didSet {
            segmentController.addTarget(self, action: #selector(changePage(_:)), for: .valueChanged)
        }
    }
    private var currentPage = 0
    private var pagerViewController = PageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    public func setViewControllers(_ viewControllers: [UIViewController]) {
        pagerViewController.orderedViewControllers = viewControllers
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
        segmentController = delegate?.viewForSegmentController()
    }
    
    private func addObserverForScrollViews() {
        guard let scrollViews = delegate?.scrollViewsForNestedScroll() else {return}
        scrollViews.forEach { (scroll) in
            scrollView.addObserverFor(scroll)
        }
    }
    
    @objc private func changePage(_ sender: UISegmentedControl) {
        pagerViewController.setPage(currentPage: currentPage, toPage: sender.selectedSegmentIndex)
        currentPage = sender.selectedSegmentIndex
    }
}

public protocol NestedScrollViewControllerDelegate {
    func scrollViewsForNestedScroll() -> [UIScrollView]
    func viewForSegmentController() -> UISegmentedControl?
}

extension UIPageViewController {
    func setPage(currentPage: Int, _ toPage: Int, animated: Bool = false) {
        var direction : UIPageViewController.NavigationDirection!
        guard currentPage != page,
              let vcList = viewControllers else {
            return
        }
        if currentPage < page {
            direction = .forward
        } else {
            direction = .reverse
        }
        if vcList.indices.contains(page) {
            self.setViewControllers([vcList[page]], direction: direction, animated: animated, completion: nil)
        }
    }
}
