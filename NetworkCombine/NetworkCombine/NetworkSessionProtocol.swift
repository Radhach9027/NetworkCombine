import Foundation

public protocol NetworkSessionProtocol {
    
    func dataTaskPublisher(for request: URLRequest) -> URLSession.DataTaskPublisher
    
    func uploadTask(with request: URLRequest,
                    fromFile fileURL: URL,
                    completionHandler: @escaping (Data?,
                                                  URLResponse?,
                                                  Error?) -> Void) -> URLSessionUploadTask
    
    func uploadTask(with request: URLRequest,
                    from bodyData: Data?,
                    completionHandler: @escaping (Data?,
                                                  URLResponse?,
                                                  Error?) -> Void) -> URLSessionUploadTask
    
    func downloadTask(with request: URLRequest,
                      completionHandler: @escaping (URL?,
                                                    URLResponse?,
                                                    Error?) -> Void) -> URLSessionDownloadTask
    
    func downloadTask(with url: URL,
                      completionHandler: @escaping (URL?,
                                                    URLResponse?,
                                                    Error?) -> Void) -> URLSessionDownloadTask
    
    func getAllTasks(completionHandler: @escaping ([URLSessionTask]) -> Void)
    
    func invalidateAndCancel()
}

extension URLSession: NetworkSessionProtocol {}
