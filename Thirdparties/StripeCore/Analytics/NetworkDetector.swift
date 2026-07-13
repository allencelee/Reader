//
//  NetworkDetector.swift
//  StripeCore
//
//  Created by Nick Porter on 7/5/23.
//

#if canImport(CoreTelephony)
import CoreTelephony
#endif
import Foundation
import SystemConfiguration

/// A class which can detect the current network type of the device
class NetworkDetector {

    static func getConnectionType() -> String? {
        #if os(macOS)
        return "Wi-Fi"
        #elseif canImport(CoreTelephony)
        let networkInfo = CTTelephonyNetworkInfo()
        let carrierType = networkInfo.serviceCurrentRadioAccessTechnology

        guard let carrierTypeName = carrierType?.first?.value else {
            return "unknown"
        }

        switch carrierTypeName {
        case CTRadioAccessTechnologyGPRS, CTRadioAccessTechnologyEdge, CTRadioAccessTechnologyCDMA1x:
            return "2G"
        case CTRadioAccessTechnologyWCDMA, CTRadioAccessTechnologyHSDPA, CTRadioAccessTechnologyHSUPA, CTRadioAccessTechnologyCDMAEVDORev0, CTRadioAccessTechnologyCDMAEVDORevA, CTRadioAccessTechnologyCDMAEVDORevB, CTRadioAccessTechnologyeHRPD:
            return "3G"
        case CTRadioAccessTechnologyLTE:
            return "4G"
        default:
            return "5G"
        }
#else
        return "Wi-Fi"
#endif
    }

}
