//
//  BasicLocationEstimatesHolder.swift
//  UserLocationPlacemarkHelper
//
//  Created by Dmitry Trimonov on 03/04/2018.
//  Copyright © 2018 Yandex, LLC. All rights reserved.
//

import Foundation

class BasicLocationEstimatesHolder: LocationEstimatesHolder {

    private(set) var bestLocationEstimate: SceneLocationEstimate? = nil {
        didSet {
            guard let bestEstimate = bestLocationEstimate else { return }
            notifier.notify( { listener in
                listener.locationEstimatesHolder(self, didUpdateBestEstimate: bestEstimate)
            })
        }
    }

    private(set) var estimates: [SceneLocationEstimate] = []

    func add(_ locationEstimate: SceneLocationEstimate) {
        estimates.append(locationEstimate)
        if let bestEstimate = bestLocationEstimate, bestEstimate < locationEstimate { return }
        bestLocationEstimate = locationEstimate
    }

    func filter(_ isIncluded: (SceneLocationEstimate) -> Bool) {
        let (passed, removed) = estimates.reduce(([SceneLocationEstimate](),[SceneLocationEstimate]())) { passedRemovedPair, estimate in
            let passed = isIncluded(estimate)
            return (passedRemovedPair.0 + (passed ? [estimate] : []),
                    passedRemovedPair.1 + (passed ? [] : [estimate]))
        }

        assert(passed.count + removed.count == estimates.count)

        estimates = passed
        if let bestEstimate = bestLocationEstimate, !removed.contains(bestEstimate) { return }
        bestLocationEstimate = estimates.sorted{ $0 < $1 }.first
    }

    func addListener(_ listener: LocationEstimatesHolderListener) {
        notifier.addListener(listener)
    }

    func removeListener(_ listener: LocationEstimatesHolderListener) {
        notifier.removeListener(listener)
    }

    private var notifier = Notifier<LocationEstimatesHolderListener>()
}
