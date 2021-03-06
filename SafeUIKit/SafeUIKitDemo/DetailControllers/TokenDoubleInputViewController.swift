//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import BigInt

class TokenDoubleInputViewController: UIViewController {

    @IBOutlet var tokenInput: TokenDoubleInput!

    @IBAction func zeroDecimals(_ sender: Any) {
        setup(decimals: 0)
    }

    @IBAction func fiveDecimals(_ sender: Any) {
        setup(decimals: 5)
    }

    @IBAction func eighteenDecimals(_ sender: Any) {
        setup(decimals: 18)
    }

    @IBAction func seventyEightDecimals(_ sender: Any) {
        setup(decimals: 78)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tokenInput.setUp(value: 0, decimals: 5, fiatConversionRate: 0.1, locale: Locale.current)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func hideKeyboard() {        
        _ = tokenInput.resignFirstResponder()
    }

    private func setup(decimals: Int) {
        tokenInput.setUp(value: 0, decimals: decimals, fiatConversionRate: 0.1, locale: Locale.current)
    }

}
