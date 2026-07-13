// This file is part of Kpapp for iOS.

import Testing
@testable import Kpapp

struct PortInputTests {

    @Test(arguments: ["", "*", "-", "0"])
    func resultsInEmpty(value: String) async throws {
        assert(PortNumber.filtered(value) == "")
    }
    
    @Test(arguments: [
        ["1": "1"],
        ["12-": "12"],
        ["65535": "65535"],
        ["655352": "65535"]
    ])
    func filteredValue(dict: [String: String]) async throws {
        for (value, result) in dict {
            assert(PortNumber.filtered(value) == result)
        }
    }

}
