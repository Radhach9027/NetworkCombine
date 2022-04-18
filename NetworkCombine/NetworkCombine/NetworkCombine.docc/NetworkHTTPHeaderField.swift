import Foundation

public enum NetworkHTTPHeaderField {
    case headerFields(fields: [NetworkHTTPHeaderKeys: NetworkHTTPHeaderValues])
    
    var headers: [NetworkHTTPHeaderKeys: NetworkHTTPHeaderValues] {
        switch self {
            case .headerFields(let httpHeaders):
                return httpHeaders
        }
    }
}

public enum NetworkHTTPHeaderKeys {
    case authentication
    case contentType
    case acceptType
    case acceptEncoding
    case requestName
    case acceptCharset
    case acceptDateTime
    case other(value: String)
}

public enum NetworkHTTPHeaderValues {
    case json
    case xml
    case image
    case json_utf8
    case formData
    case other(value: String)
}

extension NetworkHTTPHeaderKeys: Hashable {
    
    var description: String {
        switch self {
            case .authentication:
                return "Authorization"
            case .contentType:
                return "Content-Type"
            case .acceptType:
                return "Accept"
            case .acceptEncoding:
                return "Accept-Encoding"
            case .requestName:
                return "RequestName"
            case .acceptCharset:
                return "Accept-Charset"
            case .acceptDateTime:
                return "Accept-Datetime"
            case .other(let value):
                return value
        }
    }
}


extension NetworkHTTPHeaderValues: Hashable {
    
    var description: String {
        switch self {
            case .json:
                return "application/json"
            case .xml:
                return "application/x-www-form-urlencoded"
            case .image:
                return "image/png"
            case .json_utf8:
                return "application/json; charset=utf-8"
            case .formData:
                return "multipart/form-data"
            case .other(let value):
                return value
        }
    }
}

