//
//  ResponsiveLayout.swift
//  BravoBall
//
//  Created by Joshua Conklin on 4/15/25.
//

import SwiftUI

// MARK: - Responsive Layout Constants
struct ResponsiveLayout {
    static let shared = ResponsiveLayout()
    
    // Device type checks
    var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var isPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
    
    // Content width limits
    var contentMaxWidth: CGFloat {
        isPad ? 800 : .infinity
    }
    
    var contentMinPadding: CGFloat {
        isPad ? 40 : 20
    }
    
    // Component specific sizes
    var buttonMaxWidth: CGFloat {
        isPad ? 500 : 320
    }
    
    var cardMaxWidth: CGFloat {
        isPad ? 600 : .infinity
    }
    
    var gridColumns: Int {
        isPad ? 2 : 1
    }
    
    // Spacing
    var standardSpacing: CGFloat {
        isPad ? 30 : 20
    }
    
    var largeSpacing: CGFloat {
        isPad ? 40 : 25
    }
    
    // Text sizes
    var titleSize: CGFloat {
        isPad ? 28 : 22
    }
    
    var subtitleSize: CGFloat {
        isPad ? 20 : 16
    }
    
    var bodySize: CGFloat {
        isPad ? 16 : 14
    }
    
    // Component heights
    var buttonHeight: CGFloat {
        isPad ? 60 : 44
    }
    
    var cardHeight: CGFloat {
        isPad ? 200 : 160
    }
    
    // Helper functions
    func adaptiveWidth(_ geometry: GeometryProxy, maxWidth: CGFloat? = nil) -> CGFloat {
        let width = min(geometry.size.width - 2 * contentMinPadding, maxWidth ?? contentMaxWidth)
        return width
    }
    
    func adaptiveHorizontalPadding(_ geometry: GeometryProxy) -> CGFloat {
        let screenWidth = geometry.size.width
        let contentWidth = min(screenWidth, contentMaxWidth)
        return max((screenWidth - contentWidth) / 2, contentMinPadding)
    }
}

// MARK: - View Extensions
extension View {
    func responsiveWidth(_ geometry: GeometryProxy) -> some View {
        let layout = ResponsiveLayout.shared
        return self
            .frame(maxWidth: layout.adaptiveWidth(geometry))
            .frame(maxWidth: .infinity)
    }
    
    func responsiveHorizontalPadding(_ geometry: GeometryProxy) -> some View {
        let padding = ResponsiveLayout.shared.adaptiveHorizontalPadding(geometry)
        return self.padding(.horizontal, padding)
    }
    
    func adaptiveFont(_ size: CGFloat) -> some View {
        let layout = ResponsiveLayout.shared
        return self.font(.system(size: layout.isPad ? size * 1.3 : size))
    }
}

// MARK: - Grid Layout Helper
struct AdaptiveGrid: Layout {
    var minWidth: CGFloat = 300
    var spacing: CGFloat = 20
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        let columns = max(1, Int(width / minWidth))
        let spacing = spacing * CGFloat(columns - 1)
        let itemWidth = (width - spacing) / CGFloat(columns)
        
        var height: CGFloat = 0
        var currentRow: CGFloat = 0
        var currentColumn = 0
        
        for subview in subviews {
            let itemSize = subview.sizeThatFits(.unspecified)
            
            if currentColumn == columns {
                currentColumn = 0
                currentRow += itemSize.height + spacing
            }
            
            height = max(height, currentRow + itemSize.height)
            currentColumn += 1
        }
        
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let width = bounds.width
        let columns = max(1, Int(width / minWidth))
        let spacing = spacing * CGFloat(columns - 1)
        let itemWidth = (width - spacing) / CGFloat(columns)
        
        var currentPosition = bounds.origin
        var currentColumn = 0
        
        for subview in subviews {
            let itemSize = subview.sizeThatFits(.unspecified)
            
            if currentColumn == columns {
                currentColumn = 0
                currentPosition.x = bounds.origin.x
                currentPosition.y += itemSize.height + spacing
            }
            
            subview.place(
                at: CGPoint(
                    x: currentPosition.x + (itemWidth + spacing) * CGFloat(currentColumn),
                    y: currentPosition.y
                ),
                proposal: ProposedViewSize(width: itemWidth, height: itemSize.height)
            )
            
            currentColumn += 1
        }
    }
}
