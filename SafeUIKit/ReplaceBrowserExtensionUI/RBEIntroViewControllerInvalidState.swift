//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit
import ReplaceBrowserExtensionFacade

extension RBEIntroViewController {

    class InvalidState: BaseErrorState {

        override func didEnter(controller: RBEIntroViewController) {
            controller.stopIndicateLoading()
            controller.showRetry()
            controller.enableRetry()
            controller.reloadData()
            if let calculationError = error as? FeeCalculationError, calculationError == .insufficientBalance {
                controller.feeCalculation.balance.set(error: calculationError)
                controller.feeCalculation.error = FeeCalculationErrorLine(text: calculationError.localizedDescription)
            } else {
                controller.feeCalculation.error = FeeCalculationErrorLine(text: error.localizedDescription).enableIcon()
            }
            controller.feeCalculation.update()
            controller.feeCalculationView.update()
        }
    }

}
