import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectMustache
import SQLiteStORM

let server = HTTPServer()
server.serverPort = 8080
server.documentRoot = "webroot"

SQLiteConnector.db = "database.db"

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
