//
// Copyright 2018-2025 Prebid.org, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    

import UIKit

@objc(PBMModalAnimator)
final class ModalAnimator: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {

    // MARK: - Properties

    weak var modalPresentationController: ModalPresentationController?

    private var frameOfPresentedView: CGRect
    var isPresented = false

    // MARK: - Init

    init(frameOfPresentedView: CGRect) {
        self.frameOfPresentedView = frameOfPresentedView
        super.init()
    }

    // MARK: - UIViewControllerTransitioningDelegate

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresented = true
        return self
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresented = false
        return self
    }

    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {

        isPresented = true

        let presentationController = ModalPresentationController(
            presentedViewController: presented,
            presenting: presenting ?? source
        )
        presentationController.frameOfPresentedView = frameOfPresentedView
        self.modalPresentationController = presentationController

        return presentationController
    }

    // MARK: - UIViewControllerAnimatedTransitioning

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView

        if isPresented {
            guard let toView = transitionContext.view(forKey: .to) else {
                transitionContext.completeTransition(false)
                return
            }

            containerView.addSubview(toView)
            toView.alpha = 0.0

            UIView.animate(withDuration: transitionDuration(using: transitionContext)) {
                toView.alpha = 1.0
            } completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }

        } else {
            guard let fromView = transitionContext.view(forKey: .from) else {
                transitionContext.completeTransition(false)
                return
            }

            UIView.animate(withDuration: transitionDuration(using: transitionContext)) {
                fromView.alpha = 0.0
            } completion: { finished in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }

    func animationEnded(_ transitionCompleted: Bool) {
        isPresented = false
    }
}
