import Alamofire
import Foundation
import NetworkManager

public struct AlamofireClient: Client {
    private let session: Session
    public static let shared: AlamofireClient = .init(session: AF)
    
    init(session: Session) {
        self.session = session
    }
    
    public func sendRequest(url: URL, method: String, headers: [String: String], cookie: HTTPCookie?, interceptors: [NMInterceptor], body: Data?, completion: @Sendable @escaping (Result<Response<Data>, Error>) -> Void) -> NetworkManager.Request {
        let request = session.request(
            url,
            method: HTTPMethod(rawValue: method),
            parameters: nil,
            encoding: DataEncoding(data: body),
            interceptor: CookieInterceptorChain(
                interceptors: interceptors,
                cookie: cookie
            )
        )
        
        return AlamofireRequest(
            request: request.response { response in
                switch response.result {
                case .success(let data):
                    if let data,
                       let response = response.response {
                        let cookies = HTTPCookieStorage.shared.cookies(for: url) ?? []
                        completion(.success(Response(data: data, statusCode: response.statusCode, headers: headers, cookies: cookies)))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        )
    }
}
