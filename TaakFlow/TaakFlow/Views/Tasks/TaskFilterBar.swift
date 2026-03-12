// TaskFilterBar.swift
// TaakFlow — Vancoillie Studio

import SwiftUI

struct TaskFilterBar: View {
    @Binding var activeFilter: TFFilterOption
    @Binding var sortOption: TFSortOption
    @State private var showSortSheet = false

    var body: some View {
        HStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: TFSpacing.sm) {
                    ForEach(TFFilterOption.allCases) { filter in
                        FilterPillView(
                            label: filter.rawValue,
                            isActive: activeFilter == filter
                        ) {
                            activeFilter = filter
                        }
                    }
                }
                .padding(.horizontal, TFSpacing.lg)
                .padding(.vertical, TFSpacing.xs)
            }

            Button(action: { showSortSheet = true }) {
                HStack(spacing: TFSpacing.xs) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 11, weight: .semibold))
                    Text("Sorteren")
                        .font(.tfCaption())
                }
                .foregroundColor(.tfTextSecondary)
                .padding(.horizontal, TFSpacing.md)
                .padding(.vertical, TFSpacing.sm)
                .background(Color.tfBgSubtle)
                .clipShape(RoundedRectangle(cornerRadius: TFRadius.input))
            }
            .buttonStyle(.plain)
            .padding(.trailing, TFSpacing.lg)
        }
        .confirmationDialog("Sorteren op", isPresented: $showSortSheet) {
            ForEach(TFSortOption.allCases) { option in
                Button(option.rawValue) { sortOption = option }
            }
            Button("Annuleer", role: .cancel) {}
        }
    }
}
