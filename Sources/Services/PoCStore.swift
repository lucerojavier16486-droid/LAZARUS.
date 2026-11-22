import Foundation
import Combine

final class PoCStore: ObservableObject {
    private let fileName = "poc_experiments.json"

    @Published var experiments: [PoCExperiment] = []

    private var storageURL: URL? {
        FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first?.appendingPathComponent(fileName)
    }

    init() {
        load()
    }

    func load() {
        guard
            let url = storageURL,
            let data = try? Data(contentsOf: url),
            let items = try? JSONDecoder().decode(
                [PoCExperiment].self,
                from: data
            )
        else {
            return
        }

        experiments = items
    }

    func save() {
        guard
            let url = storageURL,
            let data = try? JSONEncoder().encode(experiments)
        else {
            return
        }

        try? data.write(to: url, options: .atomic)
    }

    func add(name: String, description: String, code: String = "") {
        experiments.append(
            PoCExperiment(
                name: name,
                description: description,
                code: code
            )
        )
        save()
    }

    func recordRun(id: UUID, result: String) {
        guard let index = experiments.firstIndex(where: { $0.id == id }) else {
            return
        }

        experiments[index].runCount += 1
        experiments[index].lastResult = result
        save()
    }

    func delete(id: UUID) {
        experiments.removeAll { $0.id == id }
        save()
    }
}