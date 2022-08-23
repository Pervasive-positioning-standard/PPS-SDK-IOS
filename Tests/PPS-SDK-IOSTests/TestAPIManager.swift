//
//  APIManager.swift
//  
//
//  Created by mtrec_mbp on 1/8/2022.
//

import XCTest
@testable import PPS_SDK_IOS
final class TestAPIManager: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

  
    func testGetJson() async throws {
        let instance = APIManager.getInstance()
        let url = URL(string:"https://143.89.134.2:8084/signal-modes")!
        do{
            for i in 0...5{
                try instance.getJson(url: url)
//                Thread.sleep(forTimeInterval: 100)
            }
            
        }catch{
            print("test error")
        }
        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
