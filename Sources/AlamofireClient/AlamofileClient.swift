import Alamofire
import Foundation
import NetworkManager

public struct AlamofireClient: Client {
    private let session: Session
    public static let shared: AlamofireClient = .init(session: AF)
    
    init(session: Session) {
        self.session = session
    }
    
    public func request(url: URL, method: String, headers: [String: String], cookie: HTTPCookie?, interceptors: [RestAPIInterceptor], body: Data?, completion: @Sendable @escaping (Result<Response<Data>, Error>) -> Void) -> NetworkManager.Request {
        let cookieInterceptorsChain = CookieInterceptorsChain(
            interceptors: interceptors,
            cookie: cookie
        )
        
        let request = session.request(
            url,
            method: HTTPMethod(rawValue: method),
            parameters: nil,
            encoding: DataEncoding(data: body),
            interceptor: cookieInterceptorsChain
        )
        
        return AlamofireRequest(
            request: request.response { response in
                let result: Result<(Data, URLResponse), Error>
                if let error = response.error {
                    result = .failure(error)
                } else if let data = response.data, let urlResponse = response.response {
                    result = .success((data, urlResponse))
                } else {
                    result = .failure(AFError.responseValidationFailed(reason: .dataFileNil))
                }
                
                cookieInterceptorsChain.interceptorsChain
                    .proceed(response: result, for: response.request ?? URLRequest(url: url)) { result in
                        switch result {
                        case .success(let (data, response)):
                            let cookies = HTTPCookieStorage.shared.cookies(for: url) ?? []
                            if let response = response as? HTTPURLResponse {
                                completion(.success(Response(data: data, statusCode: response.statusCode, headers: headers, cookies: cookies)))
                            }
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
            }
        )
    }
    
    public func request(url: URL, method: String, headers: [String : String], cookie: HTTPCookie?, interceptors: [RestAPIInterceptor], body: Data?, parts: [MultiPartBody], completion: @Sendable @escaping (Result<Response<Data>, any Error>) -> Void) -> NetworkManager.Request {
        if parts.isEmpty {
            return request(url: url, method: method, headers: headers, cookie: cookie, interceptors: interceptors, body: body, completion: completion)
        }
        let cookieInterceptorsChain = CookieInterceptorsChain(
            interceptors: interceptors,
            cookie: cookie
        )
        let request = session.upload(
            multipartFormData: { multipartFormData in
                
            },
            to: url,
            method: HTTPMethod(rawValue: method),
            interceptor: cookieInterceptorsChain
        )
        return AlamofireRequest(
            request: request.response { response in
                let result: Result<(Data, URLResponse), Error>
                if let error = response.error {
                    result = .failure(error)
                } else if let data = response.data, let urlResponse = response.response {
                    result = .success((data, urlResponse))
                } else {
                    result = .failure(AFError.responseValidationFailed(reason: .dataFileNil))
                }
                
                cookieInterceptorsChain.interceptorsChain
                    .proceed(response: result, for: response.request ?? URLRequest(url: url)) { result in
                        switch result {
                        case .success(let (data, response)):
                            let cookies = HTTPCookieStorage.shared.cookies(for: url) ?? []
                            if let response = response as? HTTPURLResponse {
                                completion(.success(Response(data: data, statusCode: response.statusCode, headers: headers, cookies: cookies)))
                            }
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
            }
        )
    }
}
