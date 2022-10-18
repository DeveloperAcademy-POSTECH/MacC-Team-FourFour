//
//  BottomSheetInteractiveDismissalTransition.swift
//  Samplero
//
//  Created by Minkyeong Ko on 2022/10/09.
//

import UIKit

final class BottomSheetInteractiveDismissalTransition: NSObject {

    private let stretchOffset: CGFloat = 16
    private let maxTransitionDuration: CGFloat = 0.25
    private let minTransitionDuration: CGFloat = 0.15
    private let animationCurve: UIView.AnimationCurve = .easeIn

    private weak var transitionContext: UIViewControllerContextTransitioning?

    private var heightAnimator: UIViewPropertyAnimator?
    private var offsetAnimator: UIViewPropertyAnimator?

    private var interactiveDismissal: Bool = false

    var bottomConstraint: NSLayoutConstraint?
    var heightConstraint: NSLayoutConstraint?

    private func createHeightAnimator(animating view: UIView, from height: CGFloat) -> UIViewPropertyAnimator {
        let propertyAnimator = UIViewPropertyAnimator(
            duration: minTransitionDuration,
            curve: animationCurve
        )

        heightConstraint?.constant = height
        heightConstraint?.isActive = true

        let finalHeight = height + stretchOffset

        propertyAnimator.addAnimations {
            self.heightConstraint?.constant = finalHeight
            view.superview?.layoutIfNeeded()
        }

        propertyAnimator.addCompletion { position in
            self.heightConstraint?.isActive = position == .end ? true : false
            self.heightConstraint?.constant = position == .end ? finalHeight : height
        }

        return propertyAnimator
    }

    private func createOffsetAnimator(animating view: UIView, to offset: CGFloat) -> UIViewPropertyAnimator {
        let propertyAnimator = UIViewPropertyAnimator(
            duration: maxTransitionDuration,
            curve: animationCurve
        )

        propertyAnimator.addAnimations {
            self.bottomConstraint?.constant = offset
            view.superview?.layoutIfNeeded()
        }

        propertyAnimator.addCompletion { position in
            self.bottomConstraint?.constant = position == .end ? offset : 0
        }

        return propertyAnimator
    }

    private func stretchProgress(basedOn translation: CGFloat) -> CGFloat {
        (translation > 0 ? pow(translation, 0.33) : -pow(-translation, 0.33)) / stretchOffset
    }
}

// MARK: Public methods
extension BottomSheetInteractiveDismissalTransition {

    func start(moving presentedView: UIView, interactiveDismissal: Bool) {
        self.interactiveDismissal = interactiveDismissal

        heightAnimator?.stopAnimation(false)
        heightAnimator?.finishAnimation(at: .start)
        offsetAnimator?.stopAnimation(false)
        offsetAnimator?.finishAnimation(at: .start)

        heightAnimator = createHeightAnimator(
            animating: presentedView, from: presentedView.frame.height
        )

        if !interactiveDismissal {
            offsetAnimator = createOffsetAnimator(
                animating: presentedView, to: stretchOffset
            )
        }
    }

    func move(_ presentedView: UIView, using translation: CGFloat) {
        let progress = translation / presentedView.frame.height

        let stretchProgress = stretchProgress(basedOn: translation)

        heightAnimator?.fractionComplete = stretchProgress * -1
        offsetAnimator?.fractionComplete = interactiveDismissal ? progress : stretchProgress

        transitionContext?.updateInteractiveTransition(progress)
    }

    func stop(moving presentedView: UIView, at translation: CGFloat, with velocity: CGPoint) {
        let progress = translation / presentedView.frame.height

        let stretchProgress = stretchProgress(basedOn: translation)

        heightAnimator?.fractionComplete = stretchProgress * -1
        offsetAnimator?.fractionComplete = interactiveDismissal ? progress : stretchProgress

        transitionContext?.updateInteractiveTransition(progress)

        let cancelDismiss = !interactiveDismissal || velocity.y < 500 || (progress < 0.5 && velocity.y <= 0)

        heightAnimator?.isReversed = true
        offsetAnimator?.isReversed = cancelDismiss

        if cancelDismiss {
            transitionContext?.cancelInteractiveTransition()
        } else {
            transitionContext?.finishInteractiveTransition()
        }

        if progress < 0 {
            heightAnimator?.addCompletion { _ in
                self.offsetAnimator?.stopAnimation(false)
                self.offsetAnimator?.finishAnimation(at: .start)
            }

            heightAnimator?.startAnimation()
        } else {
            offsetAnimator?.addCompletion { _ in
                self.heightAnimator?.stopAnimation(false)
                self.heightAnimator?.finishAnimation(at: .start)
            }

            offsetAnimator?.startAnimation()
        }

        interactiveDismissal = false
    }
}

// MARK: UIViewControllerAnimatedTransitioning
extension BottomSheetInteractiveDismissalTransition: UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        maxTransitionDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // This method is never called since we only care about interactive transitions,
        // and use UIKit's default transitions/animations for non-interactive transitions.
        guard let presentedView = transitionContext.view(forKey: .from) else {
            return
        }

        offsetAnimator?.stopAnimation(true)

        let offset = presentedView.frame.height
        let offsetAnimator = createOffsetAnimator(animating: presentedView, to: offset)

        offsetAnimator.addCompletion { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

        offsetAnimator.startAnimation()

        self.offsetAnimator = offsetAnimator
    }

    func interruptibleAnimator(
        using transitionContext: UIViewControllerContextTransitioning
    ) -> UIViewImplicitlyAnimating {
        guard let offsetAnimator = offsetAnimator else {
            fatalError("Somehow the offset animator was not set")
        }

        return offsetAnimator
    }
}

// MARK: UIViewControllerInteractiveTransitioning
extension BottomSheetInteractiveDismissalTransition: UIViewControllerInteractiveTransitioning {

    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        guard
            transitionContext.isInteractive,
            let presentedView = transitionContext.view(forKey: .from)
        else {
            return animateTransition(using: transitionContext)
        }

        let fractionComplete = offsetAnimator?.fractionComplete ?? 0

        offsetAnimator?.stopAnimation(true)

        let offset = presentedView.frame.height
        let offsetAnimator = createOffsetAnimator(animating: presentedView, to: offset)

        offsetAnimator.addCompletion { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

        offsetAnimator.fractionComplete = fractionComplete

        transitionContext.updateInteractiveTransition(fractionComplete)

        self.offsetAnimator = offsetAnimator
        self.transitionContext = transitionContext
    }

    var wantsInteractiveStart: Bool {
        interactiveDismissal
    }

    var completionCurve: UIView.AnimationCurve {
        animationCurve
    }

    var completionSpeed: CGFloat {
        1.0
    }
}
