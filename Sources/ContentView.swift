import SwiftUI
import UIKit

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Inicio", systemImage: "square.grid.2x2")
                }

            TerminalView()
                .tabItem {
                    Label("Terminal", systemImage: "terminal")
                }

            PoCLabView()
                .tabItem {
                    Label("PoC Lab", systemImage: "flask")
                }

            FilesView()
                .tabItem {
                    Label("Archivos", systemImage: "folder")
                }
        }
        .tint(.green)
        .preferredColorScheme(.dark)
    }
}

struct DashboardView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("LAZARUS")
                            .font(.system(size: 34, weight: .black))
                            .foregroundStyle(.green)

                        Text("IOS RESEARCH ENVIRONMENT")
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)

                        Text("Research build 0.2.0")
                            .font(.caption2)
                    }

                    GroupBox("DISPOSITIVO") {
                        VStack(alignment: .leading, spacing: 12) {
                            infoRow("Modelo", UIDevice.current.model)
                            infoRow("Sistema", UIDevice.current.systemVersion)
                            infoRow("Nombre", UIDevice.current.name)
                            infoRow("Batería", batteryLevel)
                        }
                    }

                    GroupBox("LABORATORIO") {
                        VStack(alignment: .leading, spacing: 12) {
                            infoRow("PoC disponibles", "2")
                            infoRow("Entorno", "App Sandbox")
                            infoRow("Estado", "Preparado")
                        }
                    }

                    GroupBox("SEGURIDAD") {
                        Text("Las pruebas de LAZARUS utilizan APIs públicas y archivos propios de la aplicación. No se accede a datos de otras aplicaciones.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
        }
    }

    private var batteryLevel: String {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let level = UIDevice.current.batteryLevel
        return level < 0 ? "No disponible" : "\(Int(level * 100))%"
    }

    private func infoRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.system(.body, design: .monospaced))
        }
    }
}

struct TerminalView: View {
    @State private var command = ""
    @State private var output = "LAZARUS TERMINAL 0.2.0\nEscribí help para ver los comandos.\n"

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    Text(output)
                        .font(.system(.footnote, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                        .padding()
                }

                Divider()

                HStack {
                    Text(">")
                        .foregroundStyle(.green)

                    TextField("Comando...", text: $command)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onSubmit(runCommand)

                    Button("RUN", action: runCommand)
                        .foregroundStyle(.green)
                }
                .padding()
            }
            .navigationTitle("Terminal")
        }
    }

    private func runCommand() {
        let value = command.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return }

        output += "\n> \(value)\n"

        switch value {
        case "help":
            output += """
            help
            device
            poc list
            poc run device_info
            poc run sandbox
            clear

            """

        case "device":
            output += "Model: \(UIDevice.current.model)\niOS: \(UIDevice.current.systemVersion)\n"

        case "poc list":
            output += "device_info\nsandbox\n"

        case "poc run device_info":
            output += "PASS — \(UIDevice.current.model), iOS \(UIDevice.current.systemVersion)\n"

        case "poc run sandbox":
            let path = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first?.path ?? "No disponible"

            output += "PASS — Directorio privado accesible\n\(path)\n"

        case "clear":
            output = "LAZARUS TERMINAL 0.2.0\n"

        default:
            output += "ERROR — Comando no reconocido.\n"
        }

        command = ""
    }
}

struct PoCLabView: View {
    @StateObject private var store = PoCStore()
    @State private var result = "Esperando experimento."

    var body: some View {
        NavigationStack {
            List {
                Section("EXPERIMENTOS") {
                    ForEach(store.experiments) { experiment in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(experiment.name)
                                .font(.headline)

                            Text(experiment.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text("Ejecuciones: \(experiment.runCount)")
                                .font(.caption2)

                            Button("Ejecutar") {
                                execute(experiment)
                            }
                            .foregroundStyle(.green)
                        }
                        .padding(.vertical, 5)
                    }
                    .onDelete { offsets in
                        for index in offsets {
                            store.delete(id: store.experiments[index].id)
                        }
                    }
                }

                Section("RESULTADO") {
                    Text(result)
                        .font(.system(.footnote, design: .monospaced))
                        .textSelection(.enabled)
                }

                Section {
                    Button("Restaurar experimentos iniciales") {
                        seedExperiments()
                    }
                }
            }
            .navigationTitle("PoC Laboratory")
            .onAppear {
                seedExperiments()
            }
        }
    }

    private func seedExperiments() {
        guard store.experiments.isEmpty else { return }

        store.add(
            name: "Device Info",
            description: "Consulta información pública del dispositivo.",
            code: "device_info"
        )

        store.add(
            name: "Sandbox Check",
            description: "Comprueba el directorio privado de LAZARUS.",
            code: "sandbox_check"
        )
    }

    private func execute(_ experiment: PoCExperiment) {
        let message: String

        switch experiment.code {
        case "device_info":
            message = """
            PASS — Device Info
            Modelo: \(UIDevice.current.model)
            iOS: \(UIDevice.current.systemVersion)
            """

        case "sandbox_check":
            let path = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first?.path ?? "No disponible"

            message = """
            PASS — Sandbox Check
            \(path)
            """

        default:
            message = "RECHAZADO — Experimento desconocido."
        }

        result = message
        store.recordRun(id: experiment.id, result: message)
    }
}

struct FilesView: View {
    @State private var files: [String] = []

    var body: some View {
        NavigationStack {
            List {
                Section("DOCUMENTOS DE LAZARUS") {
                    if files.isEmpty {
                        Text("Carpeta vacía")
                            .foregroundStyle(.secondary)
                    }

                    ForEach(files, id: \.self) { file in
                        Label(file, systemImage: "doc")
                    }
                }
            }
            .navigationTitle("File Explorer")
            .toolbar {
                Button(action: loadFiles) {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .onAppear(perform: loadFiles)
        }
    }

    private func loadFiles() {
        guard let url = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            files = []
            return
        }

        files = (try? FileManager.default.contentsOfDirectory(
            atPath: url.path
        )) ?? []
    }
}