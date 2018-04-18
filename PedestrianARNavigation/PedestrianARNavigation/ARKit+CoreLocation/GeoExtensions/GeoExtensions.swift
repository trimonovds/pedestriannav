import Foundation
import CoreLocation
import SceneKit
import MapKit

public struct GeometryConstants {
    public static let EarthRadius = Double(6_371_000)
    public static let LatLonEps = 1e-6
}

public extension Double {

    /// Конвертирует длину в метрах в длину по меридиану (по любому, так как они все одной длины) в радианах
    ///
    /// - Returns: длины в радианах
    public func metersToLatitude() -> Double {
        return self / GeometryConstants.EarthRadius
    }

    /// Конвертирует длину в метрах в длину по параллели
    /// переданной в параметрах (так как длина праллели зависит от широты) в радианах
    /// - Parameter lat: широта в градусах
    /// - Returns: длину в радианах
    func metersToLongitude(lat: Double) -> Double {
        return self / GeometryConstants.EarthRadius * cos(lat.degreesToRadians)
    }
}

public extension BinaryFloatingPoint {
    public var degreesToRadians: Self { return self * .pi / 180 }
    public var radiansToDegrees: Self { return self * 180 / .pi }
}


public struct SceneLocationEstimate {
    public let location: CLLocation
    public let position: SCNVector3
    public init(location: CLLocation, position: SCNVector3) {
        self.location = location
        self.position = position
    }
}

public extension SCNVector3 {
    /// Compares the position to another position, to determine the geo translation between them
    func locationTranslation(to position: SCNVector3) -> LocationTranslation {
        return LocationTranslation(
            latitudeTranslation: Double(self.z - position.z),
            longitudeTranslation: Double(position.x - self.x)
        )
    }
}

public extension SceneLocationEstimate {

    /// Translates the location by comparing with a given position
    public func translatedLocation(to position: SCNVector3) -> CLLocation {
        let translation = position - self.position
        let translatedCoordinate = location.coordinate.transform(using: CLLocationDistance(-translation.z),
                                                                 longitudinalMeters: CLLocationDistance(translation.x))
        return CLLocation(
            coordinate: translatedCoordinate,
            altitude: location.altitude,
            horizontalAccuracy: location.horizontalAccuracy,
            verticalAccuracy: location.verticalAccuracy,
            timestamp: location.timestamp
        )
    }
}


/// Haversine formula to calculate the great-circle distance between two points
///
/// - Parameters:
///   - lat1: 1-st point latitude
///   - lon1: 1-st point longitude
///   - lat2: 2-nd point latitude
///   - lon2: 2-nd point longitude
/// - Returns: Distance in meters
public func metersBetween(_ lat1: Double, _ lon1: Double, _ lat2: Double, _ lon2: Double) -> Double {
    // From here: http://www.movable-type.co.uk/scripts/latlong.html

    let sqr: (Double) -> Double = { $0 * $0 }
    let R = GeometryConstants.EarthRadius // meters

    let phi_1 = lat1.degreesToRadians
    let phi_2 = lat2.degreesToRadians
    let dPhi = (lat2 - lat1).degreesToRadians
    let dLmb = (lon2 - lon1).degreesToRadians

    let a = sqr(sin(dPhi/2)) + cos(phi_1) * cos(phi_2) * sqr(sin(dLmb/2))
    let c: Double = 2 * atan2(sqrt(a), sqrt(Double(1) - a))

    return R * c
}

public func metersBetween(_ coordinate1: CLLocationCoordinate2D, _ coordinate2: CLLocationCoordinate2D) -> Double {
    return metersBetween(coordinate1.latitude, coordinate1.longitude, coordinate2.latitude, coordinate2.longitude)
}

//(-180,180] anticlockwise is positive
public func bearingBetween(_ point1: CLLocationCoordinate2D, _ point2: CLLocationCoordinate2D) -> Double {
    let lat1 = point1.latitude.degreesToRadians
    let lon1 = point1.longitude.degreesToRadians

    let lat2 = point2.latitude.degreesToRadians
    let lon2 = point2.longitude.degreesToRadians

    let dLon = lon2 - lon1

    let y = sin(dLon) * cos(lat2)
    let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
    let radiansBearing = atan2(y, x)

    return radiansBearing.radiansToDegrees
}

/// Translation in meters between 2 locations
public struct LocationTranslation {
    public var latitudeTranslation: Double
    public var longitudeTranslation: Double

    public init(latitudeTranslation: Double, longitudeTranslation: Double) {
        self.latitudeTranslation = latitudeTranslation
        self.longitudeTranslation = longitudeTranslation
    }


}

extension LocationTranslation {
    public init(dLat: Double, dLon: Double) {
        self.init(latitudeTranslation: dLat, longitudeTranslation: dLon)
    }

    public var dLat: Double {
        return latitudeTranslation
    }

    public var dLon: Double {
        return longitudeTranslation
    }
}

public extension CLLocationCoordinate2D {

    var lat: Double {
        return latitude
    }

    var lon: Double {
        return longitude
    }

    public func transform(using latitudinalMeters: CLLocationDistance, longitudinalMeters: CLLocationDistance) -> CLLocationCoordinate2D {
        let region = MKCoordinateRegionMakeWithDistance(self, latitudinalMeters, longitudinalMeters)
        return CLLocationCoordinate2D(latitude: latitude + region.span.latitudeDelta, longitude: longitude + region.span.longitudeDelta)
    }

    /// Calculate translation between to coordinates
    func translation(toCoordinate coordinate: CLLocationCoordinate2D) -> LocationTranslation {
        let position = CLLocationCoordinate2D(latitude: self.latitude, longitude: coordinate.longitude)
        let distanceLat = metersBetween(coordinate, position)
        let dLat: Double = (coordinate.lat > position.lat ? 1 : -1) * distanceLat
        let distanceLon = metersBetween(self, position)
        let dLon: Double = (lon > position.lon ? -1 : 1) * distanceLon
        return LocationTranslation(dLat: dLat, dLon: dLon)
    }

    func translation2(toCoordinate coordinate: CLLocationCoordinate2D) -> LocationTranslation {
        let metersInOneLatDegree: Double = 2 * Double.pi * GeometryConstants.EarthRadius / 360
        let metersInOneLonDegree: ((Double) -> Double) = {
            2 * Double.pi * GeometryConstants.EarthRadius * cos($0.degreesToRadians) / 360
        }
        let distanceLat = abs(coordinate.lat - lat)
        let distanceLon = abs(coordinate.lon - lon)
        let dLat: Double = (coordinate.lat > lat ? 1 : -1) * distanceLat
        let dLon: Double = (lon > coordinate.lon ? -1 : 1) * distanceLon
        return LocationTranslation(dLat: dLat * metersInOneLatDegree, dLon: dLon * metersInOneLonDegree(lat))
    }

    func translate(bearing: Double, distanceMeters: Double) -> CLLocationCoordinate2D {
        let dLat = distanceMeters.metersToLatitude()
        let dLon = distanceMeters.metersToLongitude(lat: latitude)
        let lat1 = latitude.degreesToRadians
        let lon1 = longitude.degreesToRadians
        let lat2 = asin(sin(lat1) * cos(dLat) + cos(lat1) * sin(dLat) * cos(bearing))
        let lon2 = lon1 + atan2(sin(bearing) * sin(dLon) * cos(lat1), cos(dLon) - sin(lat1) * sin(lat2))
        return CLLocationCoordinate2D(latitude: lat2.radiansToDegrees, longitude: lon2.radiansToDegrees)
    }

    func translated(with translation: LocationTranslation) -> CLLocationCoordinate2D {
        let latitudeVector = self.translate(bearing: 0, distanceMeters: translation.dLat)
        let longitudeVector = self.translate(bearing: 90, distanceMeters: translation.dLon)
        return CLLocationCoordinate2D(latitude: latitudeVector.latitude, longitude: longitudeVector.longitude)
    }
}

public protocol CoordProvider {
    var lat: Double { get }
    var lon: Double { get }
}

extension CLLocationCoordinate2D: CoordProvider {

}

public struct LatLonRatio {

    public static func forPoint(_ point: CoordProvider) -> Double {
        return forLatitude(point.lat)
    }

    public static func forLatitude(_ latitude: Double) -> Double {
        let index = Int(abs(latitude))

        if (0...90).contains(index) {
            return LatLonRatio.coefficients[index]
        } else {
            return 1.0
        }
    }

    public static let metersInOneLatDegree: Double = 111195

    public static func metersInOneLonDegree(lat: Double) -> Double {
        return metersBetween(lat, 0, lat, 1)
    }

    private static let coefficients: [Double] = [
        1.0, 1.00015232804391, 1.00060954429882, 1.00137234599792, 1.00244189808117, 1.00381983754335,
        1.00550827956352, 1.00750982545885, 1.00982757251862, 1.012465125788, 1.01542661188575, 1.01871669495521,
        1.02234059486503, 1.02630410779339, 1.0306136293499, 1.03527618041008, 1.0402994358616, 1.04569175648715,
        1.05146222423827, 1.05762068118667, 1.06417777247591, 1.07114499363703, 1.07853474267758, 1.0863603774053,
        1.09463627850605, 1.10337791896249, 1.11260194047519, 1.12232623763436, 1.13257005068904, 1.14335406787332,
        1.15470053837925, 1.16663339721533, 1.1791784033621, 1.19236329283595, 1.20621794850391, 1.22077458876146,
        1.23606797749979, 1.25213565815623, 1.26901821507258, 1.28675956589317, 1.30540728933228, 1.32501299334881,
        1.34563272960638, 1.3673274610986, 1.39016359101668, 1.41421356237309, 1.43955653962573, 1.46627918563962,
        1.49447654986461, 1.52425308670581, 1.55572382686041, 1.58901572906575, 1.62426924548274, 1.66164014112248,
        1.70130161670408, 1.7434467956211, 1.7882916499714, 1.83607845877666, 1.88707991479986, 1.94160402641036,
        2.0, 2.06266533962731, 2.13005446818951, 2.20268926458527, 2.28117203270486, 2.3662015831525,
        2.45859333557424, 2.55930466524745, 2.66946716255401, 2.79042810962533, 2.92380440016309, 3.07155348675724,
        3.23606797749979, 3.42030361983327, 3.6279552785433, 3.86370330515627, 4.13356549443875, 4.4454114825858,
        4.80973434474413, 5.24084306416785, 5.75877048314363, 6.39245322149966, 7.18529653432771, 8.20550904812508,
        9.56677223350563, 11.4737132456699, 14.3355870262036, 19.1073226092973, 28.6537083478437, 57.2986884985506,
        1.63312393531954e+16
    ]

}



