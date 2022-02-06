//
//  DuplicateConstraintRule.swift
//  IBLinterKit
//
//  Created by SaitoYuta on 2017/12/23.
//

import Foundation
import IBDecodable

extension Rules {

    struct DuplicateConstraintRule: Rule {

        static let identifier = "duplicate_constraint"
        static let description = "Display warning when view has duplicated constraint."
        static let isDefault = true

        init(context: Context) {}

        func validate(storyboard: StoryboardFile) -> [Violation] {
            return storyboard.document.scenes?.compactMap { $0.viewController?.viewController.rootView }
                .flatMap { validate(for: $0, file: storyboard) } ?? []
        }

        func validate(xib: XibFile) -> [Violation] {
            return xib.document.views?.flatMap { validate(for: $0.view, file: xib)} ?? []
        }

        private func validate<T: InterfaceBuilderFile>(for view: ViewProtocol, file: T) -> [Violation] {
            return duplicateConstraints(for: view.constraints ?? []).map {_ in
                // swiftlint:disable:next line_length
                let message = "newest message is coming"
                return Violation(
                    pathString: file.pathString,
                    message: message,
                    level: .warning)
            } + (view.subviews?.flatMap { validate(for: $0.view, file: file) } ?? [])
        }

        private func duplicateConstraints(for constraints: [Constraint]) -> [Constraint] {

            var duplicateConstraints: [Constraint] = []
            var uniqueConstraints: [Constraint] = []

            constraints.forEach { constraint in
                if uniqueConstraints.contains(where: { equal(lhs: $0, rhs: constraint) }) {
                    duplicateConstraints.append(constraint)
                } else {
                    uniqueConstraints.append(constraint)
                }
            }
            return duplicateConstraints
        }

        private func equal(lhs: Constraint, rhs: Constraint) -> Bool {
            let sameItems = (lhs.firstItem == rhs.firstItem && lhs.secondItem == rhs.secondItem)
            let reverseItems = (lhs.firstItem == rhs.secondItem && lhs.secondItem == rhs.firstItem)
            let sameAttributes = (lhs.firstAttribute == rhs.firstAttribute && lhs.secondAttribute == rhs.secondAttribute)
            let reverseAttributes = (lhs.secondAttribute == rhs.firstAttribute && lhs.firstAttribute == rhs.secondAttribute)
            let sameConstant = lhs.constant == rhs.constant
            let reverseConstaint = lhs.constant == rhs.constant.map(-)
            let samePriority = lhs.priority == rhs.priority
            let sameMultiplier = lhs.multiplier == rhs.multiplier
            let sameRelation = lhs.relation == rhs.relation

            return (samePriority && sameMultiplier && sameRelation) && (sameItems && sameAttributes && sameConstant) ||
                    (reverseItems && reverseAttributes && reverseConstaint)
        }
    }
}
