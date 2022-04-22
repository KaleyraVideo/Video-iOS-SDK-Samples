//
// Copyright © 2019-Present. Kaleyra S.p.a. All rights reserved.
//

import Foundation

protocol UserRepository {

    func fetchAllUsers(_ completion: @escaping (Result<Contact, Error>) -> Void)
}
