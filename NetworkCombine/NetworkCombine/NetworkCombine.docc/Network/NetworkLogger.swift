import Foundation
import os

public enum LoggerCategory {
    case network, database, other(type: String)
}

enum LoggerPrivacy {
    case open, encapsulate, encrypt
}

extension LoggerCategory {
    
    var description: String {
        switch self {
            case .network:
                return "NetworkClient"
            case .database:
                return "Database"
            case .other(let type):
                return type
        }
    }
}

protocol NetworkLoggerProtocol {
    
    func logRequest(request: URLRequest,
                    error: NetworkError,
                    type: OSLogType,
                    privacy: LoggerPrivacy)
    
    func logMessage(mesaage: String,
                   type: OSLogType,
                    privacy: LoggerPrivacy)
    
    func logUrl(url: URL?,
                error: NetworkError,
                type: OSLogType,
                privacy: LoggerPrivacy)
}

public struct NetworkLogger: NetworkLoggerProtocol {
    
    private var identifier: String
    private var category: LoggerCategory
    private let logger: Logger
    
    public init(identifier: String,
         category: LoggerCategory) {
        
        self.identifier = identifier
        self.category = category
        self.logger = Logger(
            subsystem: identifier,
            category: category.description
        )
    }
    
    func logRequest(request: URLRequest,
                    error: NetworkError,
                    type: OSLogType,
                    privacy: LoggerPrivacy) {
        
        switch privacy {
            case .open:
                logger.log(level: type, "Request: \(request, privacy: .private(mask: .hash))")
            case .encapsulate:
                logger.log(level: type, "Request: \(request, privacy: .private(mask: .hash))")
            case .encrypt:
                logger.log(level: type, "Request: \(request, privacy: .private(mask: .hash))")
        }
    }
    
    func logUrl(url: URL?,
                error: NetworkError,
                type: OSLogType,
                privacy: LoggerPrivacy) {
        
        var logString = ""
        
        if let url = url {
            logString = url.absoluteString.appending("Error: \(error.localizedDescription)")
        }
        
        switch privacy {
            case .open:
                logger.log(level: type, "Request: \(logString, privacy: .public)")
            case .encapsulate:
                logger.log(level: type, "Request: \(logString, privacy: .private)")
            case .encrypt:
                logger.log(level: type, "Request: \(logString, privacy: .private(mask: .hash))")
        }
    }
    
    
    func logMessage(mesaage: String,
                    type: OSLogType,
                    privacy: LoggerPrivacy) {
        
        switch privacy {
            case .open:
                logger.log(level: type, "Message: \(mesaage, privacy: .public)")
            case .encapsulate:
                logger.log(level: type, "Message: \(mesaage, privacy: .private))")
            case .encrypt:
                logger.log(level: type, "Message: \(mesaage, privacy: .private(mask: .hash))")
        }
    }
}


