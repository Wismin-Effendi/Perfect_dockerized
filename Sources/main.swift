import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectMustache
import PostgresStORM
import Foundation

let server = HTTPServer()
server.serverPort = 8080
server.documentRoot = "webroot"

let env = ProcessInfo.processInfo.environment
PostgresConnector.host      = env["POSTGRES_HOST"] ?? ""
PostgresConnector.username  = env["POSTGRES_USER"] ?? ""
PostgresConnector.password  = env["POSTGRES_PASSWORD"] ?? ""
PostgresConnector.database  = env["POSTGRES_DB"] ?? ""

let setupObj = Acronym()
try? setupObj.setup()

let basic = BasicController()
let til = TILController()
server.addRoutes(Routes(basic.routes + til.routes))


do {
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}
