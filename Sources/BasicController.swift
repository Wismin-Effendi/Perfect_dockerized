import Foundation
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectMustache
import PostgresStORM

// Responsibility: call appropriate func & set header/body/completed 

final class BasicController {
    

    
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
    
    func helloMustache(request: HTTPRequest, response: HTTPResponse) {
        var values = MustacheEvaluationContext.MapType()
        values["name"] = "Ray"
        mustacheRequest(request: request, response: response,
                        handler: MustacheHelper(values: values),
                        templatePath: request.documentRoot + "/hello.mustache")
    }
    
    func helloMustache2(request: HTTPRequest, response: HTTPResponse) {
        var values = MustacheEvaluationContext.MapType()
        values["users"] = [
            ["name": "Ray", "email": "ray@razeware.com"],
            ["name": "Wismin", "email": "wismin@icloud.com"],
            ["name": "SeYa", "email": "seya@icloud.com"]
        ]
        mustacheRequest(request: request, response: response,
                        handler: MustacheHelper(values: values),
                        templatePath: request.documentRoot + "/hello2.mustache")
    }

    func test(request: HTTPRequest, response: HTTPResponse) {
        do {
            let json = try AcronymAPI.test()
            response.setBody(string: json)
                .setHeader(.contentType, value: "application/json")
                .completed()
        } catch {
            response.setBody(string: "Error")
                .completed(status: .internalServerError)
        }
    }
    
    var routes: [Route] {
        return [
            Route(method: .get, uri: "/", handler: helloJSON),
            Route(method: .get, uri: "/beers/{num_beers}", handler: beerSong),
            Route(method: .post, uri: "/hello", handler: helloName),
            Route(method: .get, uri: "/helloMustache", handler: helloMustache),
            Route(method: .get, uri: "/helloMustache2", handler: helloMustache2),
            Route(method: .get, uri: "/test", handler: test)
        ]
    }
}
