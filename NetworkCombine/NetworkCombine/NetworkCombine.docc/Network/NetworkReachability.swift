import Foundation
import Reachability

extension Notification.Name {
    static let ReachabilityStatusChanged = Notification.Name("ReachabilityStatusChangedNotification")
}

public final class NetworkReachability {
    enum ReachabilityStatus: Equatable {
        case connected
        case disconnected
    }
    var reachabilityObserver: ((ReachabilityStatus) -> Void)?
    private(set) var reachabilityStatus: ReachabilityStatus = .connected
    private let reachability = try! Reachability()
    public static let shared = NetworkReachability()
    
    private init() {
        setupReachability()
    }
    
    deinit {
        stopNotifier()
    }
    
    public var isReachable: Bool {
        return reachability.connection != .unavailable
    }
    
    public var isConnectedViaCellularOrWifi: Bool {
        return isConnectedViaCellular || isConnectedViaWiFi
    }
    
    public var isConnectedViaCellular: Bool {
        return reachability.connection == .cellular
    }
    
    public var isConnectedViaWiFi: Bool {
        return reachability.connection == .wifi
    }
    
    func startNotifier() {
        do {
            try reachability.startNotifier()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func stopNotifier() {
        reachability.stopNotifier()
    }
}

private extension NetworkReachability {
    func setupReachability() {
        let reachabilityStatusObserver: ((Reachability) -> ()) = { [unowned self] (reachability: Reachability) in
            self.updateReachabilityStatus(reachability.connection)
        }
        reachability.whenReachable = reachabilityStatusObserver
        reachability.whenUnreachable = reachabilityStatusObserver
    }
    
    func updateReachabilityStatus(_ status: Reachability.Connection) {
        switch status {
            case .unavailable:
            notifyReachabilityStatus(.disconnected)
        case .cellular, .wifi:
            notifyReachabilityStatus(.connected)
        }
    }
    
    func notifyReachabilityStatus(_ status: ReachabilityStatus) {
        reachabilityStatus = status
        reachabilityObserver?(status)
        NotificationCenter.default.post(
            name: Notification.Name.ReachabilityStatusChanged,
            object: nil,
            userInfo: ["ReachabilityStatus": status]
        )
    }
}
