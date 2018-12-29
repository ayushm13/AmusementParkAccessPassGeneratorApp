//
//  SeasonGuestPass.swift
//  AmusementParkAccessPassGeneratorApp
//
//  Created by Abhilash Muraleedharan on 29/12/18.
//  Copyright © 2018 AbhilashApps. All rights reserved.
//

import Foundation

class SeasonGuestPass: GuestPass {
    
    init(firstName: String? = nil, lastName: String? = nil,
         dateOfBirth: Date? = nil, streetAddress: String? = nil, city: String? = nil,
         state: String? = nil, zipcode: String? = nil) throws {
        do {
            try super.init(passType: .seasonGuestPass, firstName: firstName,
                           lastName: lastName, streetAddress: streetAddress,
                           city: city, state: state, zipcode: zipcode, dateOfBirth: dateOfBirth, projectNumber: nil, vendorCompany: nil, dateOfVisit: nil)
            printPassGenerationStatus()
        } catch MissingInformationError.inSufficientData(let error) {
            throw MissingInformationError.inSufficientData(errorMessage: error)
        } catch let error {
            throw MissingInformationError.inSufficientData(errorMessage: "\(error.localizedDescription)")
        }
    }
}