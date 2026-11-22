import Foundation

struct PoCExperiment: Identifiable, Codable {
    var id: UUID
    var name: String
    var description: String
    var code: String
    var createdAt: Date
    var runCount: Int
    var lastResult: String

    init(name: String, description: String, code: String = "") {
        self.id = UUID()
        self.name = name
        self.description = description
        self.code = code
        self.createdAt = Date()
        self.runCount = 0
        self.lastResult = "No ejecutada"
    }
}