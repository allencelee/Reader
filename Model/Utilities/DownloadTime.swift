// This file is part of Kpapp for iOS.
import Foundation
import QuartzCore

@MainActor
final class DownloadTime {
    
    /// Only consider these last seconds, when calculating the average speed, hence the remaining time
    private let considerLastSeconds: Double
    /// sampled data: seconds to % of download
    private var samples: [CFTimeInterval: Int64] = [:]
    private let totalAmount: Int64
    
    init(considerLastSeconds: Double = 2, total: Int64) {
        assert(considerLastSeconds > 0)
        assert(total > 0)
        self.considerLastSeconds = considerLastSeconds
        self.totalAmount = total
    }
    
    func update(downloaded: Int64, now: CFTimeInterval = CACurrentMediaTime()) {
        filterOutSamples(now: now)
        samples[now] = downloaded
    }
    
    func remainingTime(now: CFTimeInterval = CACurrentMediaTime()) -> CFTimeInterval {
        filterOutSamples(now: now)
        guard samples.count > 1, let (latestTime, latestAmount) = latestSample() else {
            return .infinity
        }
        let average = averagePerSecond()
        let remainingAmount = totalAmount - latestAmount
        let remainingTime = Double(remainingAmount) / average - (now - latestTime)
        guard remainingTime > 0 else {
            return 0
        }
        return remainingTime
    }
    
    private func filterOutSamples(now: CFTimeInterval) {
        samples = samples.filter { time, _ in
            time + considerLastSeconds > now
        }
    }
    
    private func averagePerSecond() -> Double {
        var averages: [Double] = []
        let allSamples = samples.sorted { dictA, dictB in
            dictA.key < dictB.key
        }
        guard let first = allSamples.first else { return .infinity }
        let firstTime = first.key
        let firstAmount = first.value
        
        let remainingSamples = allSamples.dropFirst()
        for sample in remainingSamples {
            let took = sample.key - firstTime
            let downloaded = sample.value - firstAmount
            assert(took > 0 && downloaded > 0)
            averages.append(Double(downloaded) / took)
        }
        return mean(averages)
    }
    
    private func latestSample() -> (CFTimeInterval, Int64)? {
        guard let lastTime = samples.keys.sorted().reversed().first,
              let lastAmount = samples[lastTime] else {
            return nil
        }
        return (lastTime, lastAmount)
    }
    
    private func mean(_ values: [Double]) -> Double {
        guard values.count > 0 else { return 0 }
        let sum = values.reduce(Double(0.0)) { partialResult, value in
            partialResult + value
        }
        return sum / Double(values.count)
    }
}
