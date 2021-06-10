//
//  ScrollView.swift
//  NewNestedScroll
//
//  Created by Saeed on 4/30/21.
//

import UIKit

protocol ScrollViewDelegate: class {
    var headerViewHeight: CGFloat { get }
    var headerViewOffsetHeight: CGFloat { get }
}

final class ScrollView: UIScrollView {
    weak var scrollViewDelegate: ScrollViewDelegate?
    private(set) var contentView: UIStackView!
    private var offset: CGFloat {
        guard let delegate = scrollViewDelegate else { return 0 }
        return delegate.headerViewHeight - delegate.headerViewOffsetHeight
    }
    
    private var viewObservers = [UIView]()
    func addObserverFor(_ view: UIView) {
        viewObservers.append(view)
        addContentOffsetObserver(to: view)
    }
    
    private var observing = true
    func setContentOffset(_ scrollView: UIScrollView, point: CGPoint) {
        observing = false
        scrollView.contentOffset = point
        observing = true
    }
    
    func handleScrollUp(_ scrollView: UIScrollView, change: CGFloat, oldPosition: CGPoint) {
        if contentOffset.y != 0.0 {
            if scrollView.contentOffset.y < 0.0 {
                if contentOffset.y >= 0.0 {
                    var yPos = contentOffset.y - change
                    yPos = yPos < 0 ? 0 : yPos
                    let updatedPos = CGPoint(x: contentOffset.x, y: yPos)
                    setContentOffset(self, point: updatedPos)
                    setContentOffset(scrollView, point: oldPosition)
                }
            }
        }
    }
    
    func handleScrollDown(_ scrollView: UIScrollView, change: CGFloat, oldPosition: CGPoint) {
        if contentOffset.y < offset {
            if scrollView.contentOffset.y >= 0.0 {
                var yPos = contentOffset.y - change
                yPos = yPos > offset ? offset : yPos
                let updatedPos = CGPoint(x: contentOffset.x, y: yPos)
                setContentOffset(self, point: updatedPos)
                setContentOffset(scrollView, point: oldPosition)
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard
            observing,
            let scrollView = object as? UIScrollView, scrollView != self,
            let changeValues = change as [NSKeyValueChangeKey: AnyObject]?,
            let old = changeValues[NSKeyValueChangeKey.oldKey]?.cgPointValue,
            let new = changeValues[NSKeyValueChangeKey.newKey]?.cgPointValue
        else {
            return
        }
        
        let diff = old.y - new.y
        if abs(diff) >= 1 {
            if diff > 0.0 {
                handleScrollUp(scrollView, change: diff, oldPosition: old)
            } else {
                handleScrollDown(scrollView, change: diff, oldPosition: old)
            }
        }
        
    }
    
    private func addContentOffsetObserver(to view: UIView) {
        view.addObserver(
            self,
            forKeyPath: "contentOffset",
            options: [NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.old],
            context: nil
        )
    }
    
    private func removeContentOffsetObserver(from view: UIView) {
        removeObserver(view, forKeyPath: "contentOffset", context: nil)
    }
    
    deinit {
        removeContentOffsetObserver(from: self)
        viewObservers.forEach { (view) in
            removeContentOffsetObserver(from: view)
        }
    }
    
    var contentViewHeightConstraint: NSLayoutConstraint!
    private func createContentView() {
        guard contentView == nil else { return }
        contentView = UIStackView()
        contentView.axis = .vertical
        contentView.alignment = .fill
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: offset).isActive = true
    }
    
    private func setup() {
        sizeToFit()
        translatesAutoresizingMaskIntoConstraints = false
        decelerationRate = .fast
        bounces = true
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        addContentOffsetObserver(to: self)
        createContentView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    convenience init(delegate: ScrollViewDelegate) {
        self.init(frame: .zero)
        self.scrollViewDelegate = delegate
    }
}
