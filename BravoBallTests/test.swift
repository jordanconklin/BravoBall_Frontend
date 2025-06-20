//
//
//  test.swift
//  BravoBall
//
//  Created by Joshua Conklin on 6/18/25.
//

import SwiftUI

struct UIKitScrollViewWithHeader: View {
    @State private var offset: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            // Fixed header
            HStack {
                Text("HEADER")
                    .foregroundColor(offset > 50 ? .white : .black)
                Spacer()
            }
            .padding()
            .background(Color.black.opacity(min(1, max(0, offset / 100.0))))
            .animation(.easeInOut, value: offset)

            // UIKit scroll view
            UIKitScrollView(offset: $offset)
        }
    }
}

struct UIKitScrollView: UIViewControllerRepresentable {
    @Binding var offset: CGFloat

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.alwaysBounceVertical = true

        // Add content
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        for i in 1...30 {
            let label = UILabel()
            label.text = "Item \(i)"
            label.textAlignment = .center
            label.backgroundColor = UIColor(
                hue: CGFloat(i) / 30.0,
                saturation: 0.7,
                brightness: 0.8,
                alpha: 1.0
            )
            label.textColor = .white
            label.heightAnchor.constraint(equalToConstant: 60).isActive = true
            stack.addArrangedSubview(label)
        }
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)
        vc.view.addSubview(scrollView)

        // Layout
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: vc.view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stack.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(offset: $offset)
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        var offset: Binding<CGFloat>
        init(offset: Binding<CGFloat>) {
            self.offset = offset
        }
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            offset.wrappedValue = scrollView.contentOffset.y
        }
    }
}
