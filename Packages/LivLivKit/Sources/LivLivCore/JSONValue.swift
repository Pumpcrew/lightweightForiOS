// Untyped JSON as JSONSerialization gives it, read the way the original reads JavaScript objects: a number is a finite
// double (never a boolean), a missing key and a null are both "not set".
import Foundation

public typealias JObj = [String: Any]

@inline(__always) func isNull(_ v: Any?) -> Bool { v == nil || v is NSNull }

func jbool(_ v: Any?) -> Bool? {
    guard let v, !(v is NSNull) else { return nil }
    #if canImport(Darwin)
    if let n = v as? NSNumber, CFGetTypeID(n) == CFBooleanGetTypeID() { return n.boolValue }
    return nil
    #else
    if let n = v as? NSNumber, String(cString: n.objCType) == "c" { return n.boolValue }
    return v as? Bool == true && !(v is NSNumber) ? true : nil
    #endif
}

func jnum(_ v: Any?) -> Double? {
    guard let v, !(v is NSNull) else { return nil }
    #if canImport(Darwin)
    if let n = v as? NSNumber {
        if CFGetTypeID(n) == CFBooleanGetTypeID() { return nil }
        let d = n.doubleValue
        return d.isFinite ? d : nil
    }
    return nil
    #else
    if let n = v as? NSNumber {
        if String(cString: n.objCType) == "c" { return nil }
        let d = n.doubleValue
        return d.isFinite ? d : nil
    }
    if v is Bool { return nil }
    if let d = v as? Double { return d.isFinite ? d : nil }
    if let i = v as? Int { return Double(i) }
    return nil
    #endif
}

@inline(__always) func jstr(_ v: Any?) -> String? { v as? String }
@inline(__always) func jobj(_ v: Any?) -> JObj? { v as? JObj }
@inline(__always) func jarr(_ v: Any?) -> [Any]? { v as? [Any] }

func jnums(_ v: Any?) -> [Double]? {
    guard let a = jarr(v) else { return nil }
    var out: [Double] = []
    out.reserveCapacity(a.count)
    for x in a { guard let d = jnum(x) else { return nil }; out.append(d) }
    return out
}

func jweights(_ v: Any?) -> [String: Double]? {
    guard let o = jobj(v) else { return nil }
    var out: [String: Double] = [:]
    for (k, x) in o { if let d = jnum(x) { out[k] = d } }
    return out
}

func jlabels(_ v: Any?) -> [String: String]? {
    guard let o = jobj(v) else { return nil }
    var out: [String: String] = [:]
    for (k, x) in o { if let s = x as? String { out[k] = s } }
    return out
}

public func parseJSON(_ data: Data) throws -> Any {
    do { return try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) } catch {
        throw LivLivError(.notAModel, "LivLiv: this is not JSON (\(error.localizedDescription))")
    }
}
