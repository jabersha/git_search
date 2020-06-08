//
//  WebServiceTest.swift
//  GitSearch by JabinhoTests
//
//  Created by Jaber Vieira Da Silva Shamali on 07/06/20.
//  Copyright © 2020 Jaber Vieira Da Silva Shamali. All rights reserved.
//

import Foundation
import XCTest

@testable import GitSearch_by_Jabinho

class WebServiceTest: XCTestCase {
    
    func testCall(){
        
        let master = MasterViewController()
        
        XCTAssertFalse(master.fetchingMore)
        
        
    }
}
