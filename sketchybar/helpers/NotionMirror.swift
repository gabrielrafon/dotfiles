import AppKit
import ApplicationServices

// Mirror text published by Notion Calendar's native status item. No calendar API,
// account credentials, screenshots, or calendar database access is involved.
final class NotionMirror: NSObject, NSApplicationDelegate {
    private var timer: Timer?
    private let cache = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".cache/sketchybar/notion-mirror.json")

    func applicationDidFinishLaunching(_ notification: Notification) {
        if CommandLine.arguments.contains("--authorize") {
            let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
            _ = AXIsProcessTrustedWithOptions(options as CFDictionary)
        }
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in self?.refresh() }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        refresh()
        return false
    }

    private func attribute(_ element: AXUIElement, _ name: String) -> CFTypeRef? {
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, name as CFString, &value) == .success else { return nil }
        return value
    }

    private func text(_ element: AXUIElement) -> String? {
        for key in [kAXTitleAttribute, kAXValueAttribute, kAXDescriptionAttribute, kAXHelpAttribute] {
            if let value = attribute(element, key) as? String {
                let clean = value.trimmingCharacters(in: .whitespacesAndNewlines)
                if !clean.isEmpty && clean != "Notion Calendar" && clean != "Cron" && clean != "menu extra" {
                    return clean.replacingOccurrences(of: "\n", with: " ")
                }
            }
        }
        return nil
    }

    private func refresh() {
        var payload: [String: Any] = ["updatedAt": Date().timeIntervalSince1970]
        if !AXIsProcessTrusted() {
            payload["state"] = "permission"
        } else if let notion = NSRunningApplication.runningApplications(withBundleIdentifier: "com.cron.electron").first {
            let root = AXUIElementCreateApplication(notion.processIdentifier)
            AXUIElementSetMessagingTimeout(root, 1)
            if let value = attribute(root, kAXExtrasMenuBarAttribute), CFGetTypeID(value) == AXUIElementGetTypeID() {
                let menu = unsafeBitCast(value, to: AXUIElement.self)
                let children = attribute(menu, kAXChildrenAttribute) as? [AXUIElement] ?? []
                let titles = children.compactMap { text($0) }
                if let title = titles.first {
                    payload["state"] = "ok"
                    payload["title"] = title
                } else {
                    payload["state"] = "no-event"
                }
            } else {
                payload["state"] = "no-status-item"
            }
        } else {
            payload["state"] = "not-running"
        }
        do {
            try FileManager.default.createDirectory(at: cache.deletingLastPathComponent(), withIntermediateDirectories: true)
            try JSONSerialization.data(withJSONObject: payload).write(to: cache, options: .atomic)
        } catch { NSLog("Cannot write Notion mirror: %@", error.localizedDescription) }
    }
}

let delegate = NotionMirror()
let app = NSApplication.shared
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
