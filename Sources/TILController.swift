import Foundation
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectMustache

// Responsibility: call appropriate func & set header/body/completed

final class TILController {
    
    var routes: [Route] {
        return [
            Route(method: .get, uri: "/til", handler: indexView),
            Route(method: .post, uri: "/til", handler: addAcronym),
            Route(method: .post, uri: "/til/{id}/delete", handler: deleteAcronym)
        ]
    }
    
    func indexView(request: HTTPRequest, response: HTTPResponse) {
        do {
            var values = MustacheEvaluationContext.MapType()
            
            values["acronyms"] = try AcronymAPI.allAsDictionary()
            
            mustacheRequest(request: request, response: response, handler: MustacheHelper(values: values),
                            templatePath: request.documentRoot + "/index.mustache")
        } catch {
            response.setBody(string: "Error handling request: \(error)")
                .completed(status: .internalServerError)
        }
    }
    
    func addAcronym(request: HTTPRequest, response: HTTPResponse) {
        do {
            guard let short = request.param(name: "short"), let long = request.param(name: "long") else {
                response.completed(status: .badRequest)
                return
            }
            
            _ = try AcronymAPI.newAcronym(withShort: short, long: long)
            
            response.setHeader(.location, value: "/til")
                .completed(status: .movedPermanently)
        } catch {
            response.setBody(string: "Error handling request: \(error)")
                .completed(status: .internalServerError)
        }
    }
    
    func deleteAcronym(request: HTTPRequest, response: HTTPResponse) {
        do {
            guard let idString = request.urlVariables["id"], let id = Int(idString) else {
                response.completed(status: .badRequest)
                return
            }
            
            try AcronymAPI.delete(id: id)
            
            response.setHeader(.location, value: "/til")
                .completed(status: .movedPermanently)
        } catch {
            response.setBody(string: "Error handling request: \(error)")
                .completed(status: .internalServerError)
        }
    }
    
}
