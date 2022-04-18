import Foundation
import Combine

final public class Network: NetworkProtocol {
    private var session: NetworkSessionProtocol
    private var logger: NetworkLogger?
    private var sessionDelegate: NetworkSessionDelegateProtocol?
    private var cancellable = Set<AnyCancellable>()
    private let progress: PassthroughSubject<(id: Int, progress: Double), NetworkError> = .init()
    
    public init(defaultSession: NetworkSessionProtocol = URLSession.shared,
                logger: NetworkLogger? = nil) {
        self.session = defaultSession
        self.logger = logger
    }
    
    private func updateProgress() {
        sessionDelegate?.progressSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (id, progress) in
                self?.progress.send((id, progress))
            }.store(in: &cancellable)
    }
}

    // MARK: Secondary Initializers
extension Network {
    
    public convenience init(configuration: URLSessionConfiguration,
                            delegateQueue: OperationQueue,
                            pinning: SSLPinning) {
        let delegate = NetworkSessionDelegate(pinning: pinning)
        let session = URLSession(configuration: configuration,
                                 delegate: delegate,
                                 delegateQueue: delegateQueue)
        self.init(defaultSession: session,
                  logger: nil)
    }
    
    public convenience init(configuration: URLSessionConfiguration,
                            pinning: SSLPinning) {
        let delegate = NetworkSessionDelegate(pinning: pinning)
        let session = URLSession(configuration: configuration,
                                 delegate: delegate,
                                 delegateQueue: nil)
        self.init(defaultSession: session,
                  logger: nil)
    }
    
    public convenience init(configuration: URLSessionConfiguration,
                            delegateQueue: OperationQueue,
                            pinning: SSLPinning,
                            logger: NetworkLogger) {
        let delegate = NetworkSessionDelegate(pinning: pinning)
        let session = URLSession(configuration: configuration,
                                 delegate: delegate,
                                 delegateQueue: delegateQueue)
        self.init(defaultSession: session,
                  logger: logger)
    }
}

    // MARK: Data Request
extension Network {
    
    public func request(for request: URLRequest,
                 receive: DispatchQueue) -> AnyPublisher<Data, NetworkError> {
        
        session.dataTaskPublisher(for: request)
            .receive(on: receive)
            .tryMap { [weak self] (data, response) in
                guard let error = NetworkError.validateHTTPError(urlResponse: response as? HTTPURLResponse) else {
                    return data
                }
                self?.logger?.logRequest(request: request,
                                         error: error,
                                         type: .error,
                                         privacy: .encapsulate)
                throw error
            }
            .mapError { [weak self] error in
                guard let error = error as? NetworkError else {
                    return NetworkError.apiError(reason: error.localizedDescription)
                }
                
                self?.logger?.logRequest(request: request,
                                         error: error,
                                         type: .error,
                                         privacy: .encapsulate)
                return error
            }
            .eraseToAnyPublisher()
    }
}

    // MARK: Upload Request
extension Network {
    
    public func upload(for request: URLRequest,
                fileURL: URL,
                receive: DispatchQueue) -> AnyPublisher<UploadNetworkResponse, NetworkError> {
        
        let subject: PassthroughSubject<UploadNetworkResponse, NetworkError> = .init()
        let task: URLSessionUploadTask = session.uploadTask(
            with: request,
            fromFile: fileURL
        ) { [weak self] (data, response, error) in
            guard let error = NetworkError.validateHTTPError(urlResponse: response as? HTTPURLResponse) else {
                subject.send(.response(data: data))
                return
            }
            self?.logger?.logRequest(request: request,
                                     error: error,
                                     type: .error,
                                     privacy: .encapsulate)
            subject.send(completion: .failure(error))
        }
        
        task.resume()
        return progress
            .receive(on: receive)
            .filter{ $0.id == task.taskIdentifier }
            .map { .progress(percentage: $0.progress) }
            .merge(with: subject)
            .eraseToAnyPublisher()
    }
}


    // MARK: Upload Data Request
extension Network {
    
    public func upload(with request: URLRequest,
                from bodyData: Data?,
                receive: DispatchQueue) -> AnyPublisher<UploadNetworkResponse, NetworkError> {
        
        let subject: PassthroughSubject<UploadNetworkResponse, NetworkError> = .init()
        let task: URLSessionUploadTask = session.uploadTask(with: request,
                                                            from: bodyData,
                                                            completionHandler: { [weak self] (data, response, error) in
            guard let error = NetworkError.validateHTTPError(urlResponse: response as? HTTPURLResponse) else {
                subject.send(.response(data: data))
                return
            }
            self?.logger?.logRequest(request: request,
                                     error: error,
                                     type: .error,
                                     privacy: .encapsulate)
            subject.send(completion: .failure(error))
        })
        
        task.resume()
        return progress
            .receive(on: receive)
            .filter{ $0.id == task.taskIdentifier }
            .map { .progress(percentage: $0.progress) }
            .merge(with: subject)
            .eraseToAnyPublisher()
    }
}


    // MARK: Download via request
extension Network {
    
    public func download(for request: URLRequest,
                  receive: DispatchQueue) -> AnyPublisher<DownloadNetworkResponse, NetworkError> {
        
        let subject: PassthroughSubject<DownloadNetworkResponse, NetworkError> = .init()
        let task: URLSessionDownloadTask = session.downloadTask(with: request) { [weak self] (url, response, error) in
            guard let error = NetworkError.validateHTTPError(urlResponse: response as? HTTPURLResponse) else {
                subject.send(.response(data: url))
                return
            }
            self?.logger?.logRequest(request: request,
                                     error: error,
                                     type: .error,
                                     privacy: .encapsulate)
            subject.send(completion: .failure(error))
        }
        
        task.resume()
        return progress
            .receive(on: receive)
            .filter{ $0.id == task.taskIdentifier }
            .map { .progress(percentage: $0.progress) }
            .merge(with: subject)
            .eraseToAnyPublisher()
    }
}


    // MARK: Download via url
extension Network {
    
    public func download(for url: URL,
                  receive: DispatchQueue) -> AnyPublisher<DownloadNetworkResponse, NetworkError> {
        
        let subject: PassthroughSubject<DownloadNetworkResponse, NetworkError> = .init()
        let task: URLSessionDownloadTask = session.downloadTask(with: url) {[weak self]  (url, response, error) in
            guard let error = NetworkError.validateHTTPError(urlResponse: response as? HTTPURLResponse) else {
                subject.send(.response(data: url))
                return
            }
            self?.logger?.logUrl(url: url,
                                 error: error,
                                 type: .error,
                                 privacy: .encapsulate)
            subject.send(completion: .failure(error))
        }
        
        task.resume()
        return progress
            .receive(on: receive)
            .filter{ $0.id == task.taskIdentifier }
            .map { .progress(percentage: $0.progress) }
            .merge(with: subject)
            .eraseToAnyPublisher()
    }
}

    // MARK: Cancel Tasks
extension Network {
    
    public func cancelAllTasks() {
        session.invalidateAndCancel()
    }
    
    public func cancelTaskWithUrl(url: URL) {
        session.getAllTasks { tasks in
            tasks
                .filter { $0.state == .running }
                .filter { $0.originalRequest?.url == url }.first?
                .cancel()
        }
    }
}
