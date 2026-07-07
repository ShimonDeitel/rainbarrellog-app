import Foundation

struct CheckEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var date: Date
    var fillLevel: String
    var notes: String = ""
    var createdAt: Date = Date()
}
