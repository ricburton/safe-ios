//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import CommonImplementations
import Database

extension TokenInt: DBSerializable {

    public var serializedValue: SQLBindable {
        return String(self)
    }

    public init?(serializedValue: String?) {
        guard let value = serializedValue else { return nil }
        self.init(value)
    }

}
