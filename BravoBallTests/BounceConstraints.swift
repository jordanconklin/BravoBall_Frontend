//
//  BounceConstraints.swift
//  BravoBall
//
//  Created by Joshua Conklin on 6/19/25.
//

import SwiftUI

struct LimitedBounceScrollView<Content: View>: UIViewRepresentable {
    let content: Content
    let bounceLimit: CGFloat // Maximum bounce distance in points
    
    init(bounceLimit: CGFloat = 100, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.bounceLimit = bounceLimit
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(bounceLimit: bounceLimit)
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.backgroundColor = .clear
        
        // Embed SwiftUI content
        let hosting = UIHostingController(rootView: content)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        hosting.view.backgroundColor = .clear
        scrollView.addSubview(hosting.view)
        
        // Constraints
        NSLayoutConstraint.activate([
            hosting.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hosting.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hosting.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        if let hostingController = uiView.subviews.first?.next as? UIHostingController<Content> {
            hostingController.rootView = content
        }
    }
    
    // Coordinator to handle scroll view delegate
    class Coordinator: NSObject, UIScrollViewDelegate {
        let bounceLimit: CGFloat
        
        init(bounceLimit: CGFloat) {
            self.bounceLimit = bounceLimit
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            // Limit top bounce
            if scrollView.contentOffset.y < -bounceLimit {
                scrollView.contentOffset.y = -bounceLimit
            }
            
            // Limit bottom bounce
            let maxContentOffset = max(0, scrollView.contentSize.height - scrollView.bounds.size.height)
            if scrollView.contentOffset.y > maxContentOffset + bounceLimit {
                scrollView.contentOffset.y = maxContentOffset + bounceLimit
            }
        }
    }
}
