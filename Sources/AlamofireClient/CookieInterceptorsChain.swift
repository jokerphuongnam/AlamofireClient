import NetworkManager
import Foundation
import Alamofire

struct CookieInterceptorsChain: RequestInterceptor {
    let interceptorsChain: RestAPIInterceptorChain
    private let cookie: HTTPCookie?
    
    init(interceptors: [RestAPIInterceptor], cookie: HTTPCookie?) {
        self.interceptorsChain = RestAPIInterceptorChain(interceptors: interceptors)
        self.cookie = cookie
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        var currentRequest = urlRequest
        if let cookie {
            currentRequest.applyCookie(cookie)
        }
        interceptorsChain
            .proceed(request: urlRequest) { result in
                completion(result)
            }
    }
}
