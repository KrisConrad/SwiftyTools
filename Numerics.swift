//
//  Numerics.swift
//
//
//  Created by Kris Conrad on 9/25/17.
//  Copyright © 2017 SquadPod. All rights reserved.
//

import Foundation

extension Numeric {
    /// Base 10
    var KB: Self { return self * 1000 }
    /// Base 10
    var MB: Self { return KB * 1000 }
    /// Base 10
    var GB: Self { return MB * 1000 }
    /// Base 10
    var TB: Self { return GB * 1000 }
    /// Base 10
    var PB: Self { return TB * 1000 }
    /// Base 10
    var EB: Self { return PB * 1000 }
    /// Base 10
    var ZB: Self { return EB * 1000 }
    /// Base 10
    var YB: Self { return ZB * 1000 }

    /// Base 2
    var KiB: Self { return self * 1024 }
    /// Base 2
    var MiB: Self { return KiB * 1024 }
    /// Base 2
    var GiB: Self { return MiB * 1024 }
    /// Base 2
    var TiB: Self { return GiB * 1024 }
    /// Base 2
    var PiB: Self { return TiB * 1024 }
    /// Base 2
    var EiB: Self { return PiB * 1024 }
    /// Base 2
    var ZiB: Self { return EiB * 1024 }
    /// Base 2
    var YiB: Self { return ZiB * 1024 }

    // Time
    var minutes: Self { self * 60 }
    var hours: Self { self.minutes * 60 }
    var days: Self { self.hours * 24 }
    var weeks: Self { self.days * 7 }
    /// Rounded to 30 days
    var months: Self { self.days * 30 }
    /// Non leap year
    var years: Self { self.days * 365 }
}

extension BinaryInteger {
    /// Converts the value, as bytes, into a human readable string
    func fileSizeString(baseTen: Bool) -> String {
        guard self > 0 else { return "" }
        // Bytes, Kilo, Mega, Giga, Tera, Peta, Exa, Zetta, Yotta
        let abbreviations = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"]

        var calculatedSize = Float(self)
        let denominator: Float = baseTen ? 1000 : 1024
        var sizeString = ""
        var i = 0

        while calculatedSize >= denominator, i < abbreviations.count {
            i += 1
            calculatedSize /= denominator
        }

        let roundedSize = ((calculatedSize * 10).rounded(.toNearestOrAwayFromZero) / 10)

        sizeString = "\(String(format: i < 1 ? "%.0f" : "%.1f", roundedSize)) \(abbreviations[i])"

        return sizeString
    }
}
