import SwiftUI
import UIKit

struct ContentView: View {
    @State private var showNextScreen = false

    var body: some View {
        VStack {
            Text("Shake the device to show DeveloperView")
                .padding()
            Button("Next screen") {
                showNextScreen.toggle()
            }

        }
        .onShake {
            UIViewController.presentDeveloperView()
        }
        .sheet(isPresented: $showNextScreen) {
            Text("Next screen")
        }
    }
}

extension UIViewController {
    static func presentDeveloperView() {
        guard let topController = UIViewController.topMostViewController() else { return }
        let swiftUIView = DeveloperView()
        let hostingController = UIHostingController(rootView: swiftUIView)
        topController.present(hostingController, animated: true)
    }

    static func topMostViewController() -> UIViewController? {
        guard let keyWindow = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
            .first else {
            return nil
        }

        var topController = keyWindow.rootViewController
        while let presentedViewController = topController?.presentedViewController {
            topController = presentedViewController
        }

        return topController
    }
}

struct DeveloperView: View {
    var body: some View {
        VStack {
            Text("Developer View")
                .font(.largeTitle)
                .padding()

            Text("This sheet was presented from the top-most view controller!")
                .padding()

            Button("Dismiss") {
                dismiss()
            }
        }
        .padding()
    }

    private func dismiss() {
        if let topController = UIViewController.topMostViewController() {
            topController.dismiss(animated: true)
        }
    }
}
