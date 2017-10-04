import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectMustache

let server = HTTPServer()
server.serverPort = 8080
server.documentRoot = "webroot"


func helloJSON(request: HTTPRequest, response: HTTPResponse) {
    do {
        try response.setBody(json: ["message": "Hello, JSON!"])
                .setHeader(.contentType, value: "application/json")
                .completed()
    } catch {
        response.setBody(string: "Error")
            .completed(status: .internalServerError)
    }
}

func beerSong(request: HTTPRequest, response: HTTPResponse) {
    do {
        guard let numBeerString = request.urlVariables["num_beers"],
            let numBeersInt = Int(numBeerString) else {
                response.completed(status: .badRequest)
                return
        }
        
        try response.setBody(json: ["message": "Take one down, pass it around, \(numBeersInt - 1) bottle of beer on the wall..."])
            .setHeader(.contentType, value: "application/json")
            .completed()
        
    } catch {
        response.setBody(string: "Error")
            .completed(status: .internalServerError)
    }
}

func helloName(request: HTTPRequest, response: HTTPResponse) {
    do {
        guard let name = request.param(name: "name") else {
            response.completed(status: .badRequest)
            return
        }
        
        try response.setBody(json: ["message": "Hello, \(name)!"])
            .setHeader(.contentType, value: "application/json")
            .completed()
    } catch {
        response.setBody(string: "Error")
            .completed(status: .internalServerError)
    }
}

var routes = Routes()
routes.add(method: .get, uri: "/", handler: helloJSON(request:response:))
routes.add(method: .get, uri: "/beers/{num_beers}", handler: beerSong(request:response:))
routes.add(method: .post, uri: "/hello", handler: helloName(request:response:))
server.addRoutes(routes)

do {
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}
