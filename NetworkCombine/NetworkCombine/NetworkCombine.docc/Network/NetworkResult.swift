import Foundation

public enum NetworkResult <S, E> {
    case success(S)
    case error(E)
}

public enum UploadNetworkResponse {
    case progress(percentage: Double)
    case response(data: Data?)
}

public enum DownloadNetworkResponse {
    case progress(percentage: Double)
    case response(data: URL?)
}
