import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectMustache
import SQLiteStORM

SQLiteConnector.db = "database.db"

let setupObj = Acronym()
try? setupObj.setup()

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
        // Save acronym 
        let acronym = Acronym()
        acronym.short = "AFK"
        acronym.long = "Away From Keyboard"
        try acronym.save { id in
            acronym.id = id as! Int
        }
        
        // Get all acronyms 
        let getObj = Acronym()
        try getObj.findAll()
        let acronyms = getObj.rows()
        
        try response.setBody(json: acronyms)
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
routes.add(method: .get, uri: "/helloMustache", handler: helloMustache(request:response:))
routes.add(method: .get, uri: "/helloMustache2", handler: helloMustache2(request:response:))
routes.add(method: .get, uri: "/test", handler: test)
server.addRoutes(routes)

do {
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}
