import AppKit
import CoreLocation
import CoreWLAN
import SystemConfiguration

// Read the active network locally. Location authorization is used only to unlock
// CoreWLAN's SSID; this helper never requests geographic coordinates.
final class NetworkStatus: NSObject, NSApplicationDelegate, CLLocationManagerDelegate {
    private let location = CLLocationManager()
    private var timer: Timer?
    private let cache = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".cache/sketchybar/network.json")

    func applicationDidFinishLaunching(_ notification: Notification) {
        location.delegate = self
        if CommandLine.arguments.contains("--authorize") {
            location.requestWhenInUseAuthorization()
        }
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            self?.refresh()
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        refresh()
        return false
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) { refresh() }

    private func refresh() {
        let store = SCDynamicStoreCreate(nil, "SketchyBar Network" as CFString, nil, nil)
        func state(_ key: String) -> [String: Any] {
            guard let store else { return [:] }
            return SCDynamicStoreCopyValue(store, key as CFString) as? [String: Any] ?? [:]
        }
        let ipv4 = state("State:/Network/Global/IPv4")
        let ipv6 = state("State:/Network/Global/IPv6")
        let active = ipv4["PrimaryInterface"] != nil ? ipv4 : ipv6
        let interface = active["PrimaryInterface"] as? String
        var label = "Disconnected"
        var kind = "disconnected"
        if let interface {
            if CWWiFiClient.shared().interfaceNames()?.contains(interface) == true {
                kind = "wifi"
                let ssid = CWWiFiClient.shared().interface(withName: interface)?.ssid()
                label = (ssid?.isEmpty == false && ssid != "<redacted>") ? ssid! : "Wi-Fi"
            } else if interface.hasPrefix("utun") || interface.hasPrefix("ppp") {
                kind = "vpn"
                label = "VPN"
            } else {
                kind = "ethernet"
                label = "Ethernet"
                if let service = active["PrimaryService"] as? String,
                   let name = state("Setup:/Network/Service/\(service)")["UserDefinedName"] as? String,
                   !name.isEmpty { label = name }
            }
        }
        let payload: [String: Any] = [
            "label": label,
            "kind": kind,
            "locationAuthorization": location.authorizationStatus.rawValue,
            "connected": interface != nil,
            "updatedAt": Date().timeIntervalSince1970
        ]
        do {
            try FileManager.default.createDirectory(at: cache.deletingLastPathComponent(), withIntermediateDirectories: true)
            try JSONSerialization.data(withJSONObject: payload).write(to: cache, options: .atomic)
        } catch { NSLog("Cannot write network status: %@", error.localizedDescription) }
    }
}

let delegate = NetworkStatus()
let app = NSApplication.shared
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
