//
//  Copyright © 2019 Bandyer. All rights reserved.
//

import Foundation

protocol UserRepository {

    func fetchAllUsers(_ completion: @escaping (Result<Contact, Error>) -> Void)
}
