import Foundation
import Combine

public protocol NetworkProtocol {
    
    func request(for request: URLRequest,
                 receive: DispatchQueue) -> AnyPublisher<Data, NetworkError>
    
    func upload(for request: URLRequest,
                fileURL: URL,
                receive: DispatchQueue) -> AnyPublisher<UploadNetworkResponse, NetworkError>
    
    func upload(with request: URLRequest,
                from bodyData: Data?,
                receive: DispatchQueue) -> AnyPublisher<UploadNetworkResponse, NetworkError>
    
    func download(for request: URLRequest,
                  receive: DispatchQueue) -> AnyPublisher<DownloadNetworkResponse, NetworkError>
    
    func download(for url: URL,
                  receive: DispatchQueue) -> AnyPublisher<DownloadNetworkResponse, NetworkError>
    
    func cancelAllTasks()
    
    func cancelTaskWithUrl(url: URL)
    
    var isInternetReachable: Bool { get }
}
