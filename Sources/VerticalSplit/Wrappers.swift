//
//  Wrappers.swift
//  VerticalSplit
//
//  Created by Vedant Gurav on 28/02/2024.
//

import SwiftUI

struct TopWrapper<Content: View, Overlay: View>: View {
    var minimise: CGFloat
    var overscroll: CGFloat
    var isFull: Bool
    var isShowingAccessories: Bool
    var bgColor: Color
    @ViewBuilder var content: () -> Content
    @ViewBuilder var overlay: () -> Overlay
    
    let bottomSafeArea = SafeAreaInsetsKey.defaultValue.smartBottom
    let displayCornerRadius = UIScreen.main.displayCornerRadius
    let screenWidth = UIApplication.shared.screenSize.width
    
    var cornerRadius: CGFloat {
        isFull && !isShowingAccessories ? displayCornerRadius + overscroll * 2 : 22
    }
    
    var body: some View {
        GeometryReader { _ in
            ZStack {
                content()
            }
            .frame(maxWidth: screenWidth, maxHeight: .infinity, alignment: .top)
            .safeAreaPadding(.top, SafeAreaInsetsKey.defaultValue.top)
            .safeAreaPadding(.bottom, isFull && !isShowingAccessories ? lil + SafeAreaInsetsKey.defaultValue.bottom - 8 : 0)
        }
        .scaleEffect(1 - (1 - minimise) * 0.15, anchor: .top)
        .blur(radius: (1 - minimise) * 8)
        .overlay { bgColor.opacity(1 - minimise).allowsHitTesting(false) }
        .overlay(alignment: .bottom, content: {
            overlay()
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: lil)
                .opacity(1 - minimise)
                .blur(radius: minimise * 8)
                .offset(y: 16 * minimise)
                .scaleEffect(1 + minimise * 0.15)
                .allowsHitTesting(minimise == 0)
        })
        .mask { RoundedRectangle(cornerRadius: cornerRadius, style: .continuous) }
        .background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(bgColor)
                .padding(.top, -200)
        }
        .offset(y: isShowingAccessories && isFull ? -(spacing * 2 + bottomSafeArea) : 0)
        .scaleEffect(isFull ? 1 : 1 + min(0, overscroll / 800), anchor: isFull ? .center : .bottom)
        .ignoresSafeArea()
    }
}

import SwiftUI

/// Shape qui n’arrondit que certains coins
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = []

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct BottomWrapper<Content: View, Overlay: View>: View {
    var minimise: CGFloat
    var overscroll: CGFloat
    var isFull: Bool
    var isShowingAccessories: Bool
    var bgColor: Color
    @ViewBuilder var content: () -> Content
    @ViewBuilder var overlay: () -> Overlay

    // Constantes d’environnement
    let topSafeArea = SafeAreaInsetsKey.defaultValue.top
    let displayCornerRadius = UIScreen.main.displayCornerRadius
    let screenWidth = UIApplication.shared.screenSize.width

    /// Rayon dynamique selon l’état
    var cornerRadius: CGFloat {
        isFull && !isShowingAccessories
            ? displayCornerRadius - overscroll * 2
            : 22
    }

    var body: some View {
        GeometryReader { _ in
            ZStack {
                content()
            }
            .frame(maxWidth: screenWidth, maxHeight: .infinity, alignment: .top)
            .safeAreaPadding(
                .top,
                isFull && !isShowingAccessories
                    ? lil + SafeAreaInsetsKey.defaultValue.top - 8
                    : 0
            )
            .safeAreaPadding(.bottom, SafeAreaInsetsKey.defaultValue.bottom)
        }
        // Effets de position/échelle/blur en fonction du mini-état
        .scaleEffect(1 - (1 - minimise) * 0.15, anchor: .bottom)
        .blur(radius: (1 - minimise) * 8)
        // Fond semi-opaque sous le contenu
        .overlay { bgColor.opacity(1 - minimise).allowsHitTesting(false) }
        // Overlay en haut (mini barre, titre…)
        .overlay(alignment: .top) {
            overlay()
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: lil)
                .opacity(1 - minimise)
                .blur(radius: minimise * 8)
                .offset(y: -16 * minimise)
                .scaleEffect(1 + minimise * 0.15)
                .allowsHitTesting(minimise == 0)
        }
        // --- REMPLACEMENT DU MASK GLOBAL ---
        // Ne plus arrondir tous les coins : on ne clip que le bas
        .clipShape(
            RoundedCorner(
                radius: cornerRadius,
                corners: [.bottomLeft, .bottomRight]
            )
        )
        // Fond derrière le contenu, même forme
        .background {
            RoundedCorner(
                radius: cornerRadius,
                corners: [.bottomLeft, .bottomRight]
            )
            .fill(bgColor)
            .padding(.bottom, -200)
        }
        // Décalage lorsque le menu accessoires est ouvert
        .offset(y: isShowingAccessories && isFull
                ? (spacing * 2 + topSafeArea)
                : 0
        )
        // Effet d’overscroll
        .scaleEffect(
            isFull
                ? 1
                : 1 - max(0, overscroll / 800),
            anchor: isFull ? .center : .top
        )
        .ignoresSafeArea()
    }
}
