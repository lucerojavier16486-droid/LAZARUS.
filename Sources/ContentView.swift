import SwiftUI
import UIKit

struct ContentView: View {
    @State private var report = DiagnosticReport()
    var body: some View {
        NavigationStack {
            List {
                Section("Dispositivo") {
                    row("Modelo", report.model)
                    row("Sistema", report.os)
                    row("Nombre", report.name)
                    row("Arquitectura", report.arch)
                }
                Section("LAZARUS") {
                    row("Versión", "0.1.0")
                    row("Bundle ID", Bundle.main.bundleIdentifier ?? "N/D")
                    row("Entorno", "Sandbox estándar de iOS")
                }
                Section {
                    ShareLink(item: report.text) {
                        Label("Exportar informe", systemImage: "square.and.arrow.up")
                    }
                    Button("Actualizar datos", systemImage: "arrow.clockwise") {
                        report = DiagnosticReport()
                    }
                } footer: {
                    Text("Solo utiliza APIs públicas. No modifica iOS ni realiza jailbreak.")
                }
            }
            .navigationTitle("LAZARUS")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Text("RESEARCH").font(.caption2).foregroundStyle(.secondary)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value).foregroundStyle(.secondary).multilineTextAlignment(.trailing)
        }
    }
}

struct DiagnosticReport {
    let model = UIDevice.current.model
    let os = "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
    let name = UIDevice.current.name
    let arch: String = {
        #if arch(arm64)
        return "arm64"
        #elseif arch(x86_64)
        return "x86_64"
        #else
        return "Desconocida"
        #endif
    }()
    let date = ISO8601DateFormatter().string(from: Date())

    var text: String {
        """
        LAZARUS Research Report
        Generated: \(date)
        Device: \(model)
        Name: \(name)
        OS: \(os)
        Architecture: \(arch)
        App: 0.1.0
        Bundle ID: \(Bundle.main.bundleIdentifier ?? "unknown")
        """
    }
}
