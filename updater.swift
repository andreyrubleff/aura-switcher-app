import Cocoa
import Security

/// Update in one click — only when the user clicks «Check for updates…», never in the background.
/// Reads the site's update.json (version + download link), downloads the new build from GitHub Releases,
/// checks that it is signed with AURA's own certificate, replaces this app and relaunches it.
/// Anything goes wrong → offer the site's update page instead.
enum Updater {
    #if DEBUG   // manual tests only: a release build always reads the site
    static let manifest = ProcessInfo.processInfo.environment["AURA_UPDATE_MANIFEST"].flatMap(URL.init(string:)) ?? site
    #else
    static let manifest = site
    #endif
    static let site = URL(string: "https://klbk.github.io/aura-switcher/update.json")!
    /// downloads only from our GitHub releases, whatever the manifest says
    static let downloads = "https://github.com/klbk/aura-switcher/releases/download/"
    /// our signing certificate (build.sh signs with the «AURA Switcher» identity)
    static let requirement = #"identifier "com.chernov.aura" and certificate root = H"b30424a8e21ddea70fa9317cfa686590baefef24""#
    static var current: String { Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0" }

    static func newer(_ a: String, than b: String) -> Bool {
        let x = a.split(separator: ".").map { Int($0) ?? 0 }, y = b.split(separator: ".").map { Int($0) ?? 0 }
        for i in 0..<max(x.count, y.count) where (i < x.count ? x[i] : 0) != (i < y.count ? y[i] : 0) {
            return (i < x.count ? x[i] : 0) > (i < y.count ? y[i] : 0)
        }
        return false
    }

    static func check() {
        URLSession.shared.dataTask(with: URLRequest(url: manifest, cachePolicy: .reloadIgnoringLocalCacheData)) { data, _, _ in
            let j = data.flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] }
            DispatchQueue.main.async {
                guard let j, let v = j["version"] as? String, let m = j["mac"] as? String, m.hasPrefix(downloads),
                      let mac = URL(string: m) else { return failed() }
                guard newer(v, than: current) else { return say(L("updLatest").replacingOccurrences(of: "{v}", with: current)) }
                let a = NSAlert()
                a.messageText = L("updNew").replacingOccurrences(of: "{v}", with: v)
                a.addButton(withTitle: L("updNow")); a.addButton(withTitle: L("updNotes")); a.addButton(withTitle: L("updLater"))
                NSApp.activate(ignoringOtherApps: true)
                switch a.runModal() {
                case .alertFirstButtonReturn: install(mac, version: v)
                case .alertSecondButtonReturn: NSWorkspace.shared.open(updatePageURL())
                default: break
                }
            }
        }.resume()
    }

    static func install(_ url: URL, version: String) {
        URLSession.shared.downloadTask(with: url) { file, _, _ in
            let ok = file.map { replace($0, version: version) } ?? false
            DispatchQueue.main.async {
                guard ok else { return failed() }
                // the new copy starts once this one has quit
                let p = Process(); p.executableURL = URL(fileURLWithPath: "/bin/sh")
                p.arguments = ["-c", "sleep 1; /usr/bin/open \"$0\"", Bundle.main.bundlePath]
                try? p.run()
                NSApp.terminate(nil)
            }
        }.resume()
    }

    /// unzip, check the signature and the version, swap the bundle in place
    static func replace(_ zip: URL, version: String, into target: URL = Bundle.main.bundleURL) -> Bool {
        let fm = FileManager.default
        let dir = fm.temporaryDirectory.appendingPathComponent("aura-update-\(UUID().uuidString)")
        defer { try? fm.removeItem(at: dir) }
        let unzip = Process(); unzip.executableURL = URL(fileURLWithPath: "/usr/bin/ditto")
        unzip.arguments = ["-x", "-k", zip.path, dir.path]
        guard (try? unzip.run()) != nil else { return false }
        unzip.waitUntilExit()
        guard unzip.terminationStatus == 0,
              let app = fm.enumerator(at: dir, includingPropertiesForKeys: nil)?
                  .compactMap({ $0 as? URL }).first(where: { $0.pathExtension == "app" }) else { return false }
        var code: SecStaticCode?, req: SecRequirement?
        guard SecStaticCodeCreateWithPath(app as CFURL, [], &code) == errSecSuccess, let code,
              SecRequirementCreateWithString(requirement as CFString, [], &req) == errSecSuccess,
              SecStaticCodeCheckValidity(code, SecCSFlags(rawValue: kSecCSCheckAllArchitectures | kSecCSStrictValidate | kSecCSCheckNestedCode),
                                         req) == errSecSuccess,
              // exactly the version the manifest announced, and newer than this one: an old signed build can't come back
              let info = Bundle(url: app)?.infoDictionary, info["CFBundleIdentifier"] as? String == "com.chernov.aura",
              let got = info["CFBundleShortVersionString"] as? String, got == version, newer(got, than: current)
        else { return false }
        return (try? fm.replaceItemAt(target, withItemAt: app)) != nil
    }

    static func say(_ text: String) {
        let a = NSAlert(); a.messageText = text
        NSApp.activate(ignoringOtherApps: true); a.runModal()
    }

    static func failed() {
        let a = NSAlert(); a.messageText = L("updFail")
        a.addButton(withTitle: "OK"); a.addButton(withTitle: L("updLater"))
        NSApp.activate(ignoringOtherApps: true)
        if a.runModal() == .alertFirstButtonReturn { NSWorkspace.shared.open(updatePageURL()) }
    }
}

