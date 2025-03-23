import NetworkManager
import Alamofire

struct AlamofireRequest: NetworkManager.Request {
    private let request: Alamofire.Request
    
    init(request: Alamofire.Request) {
        self.request = request
    }
    
    func resume() {
        request.resume()
    }
    
    func cancel() {
        request.cancel()
    }
}
