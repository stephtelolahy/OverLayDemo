import SwiftUI
import UIKit

struct ContentView: View {
    @State private var showSheet = false
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
            //            showSheet.toggle()
            presentDeveloperView()
        }
        .sheet(isPresented: $showSheet) {
            Text("Developer view")
                .font(.title)
        }
        .sheet(isPresented: $showNextScreen) {
            Text("Next screen")
        }
    }

    private func presentDeveloperView() {
        guard let topController = UIViewController.topMostViewController() else { return }

        // Create a SwiftUI view wrapped inside a UIHostingController
        let swiftUIView = DeveloperView()
        let hostingController = UIHostingController(rootView: swiftUIView)

        // Present it as a sheet
        hostingController.modalPresentationStyle = .automatic
        topController.present(hostingController, animated: true, completion: nil)
    }
}

extension UIViewController {
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
            Text("Hello, World!")
                .font(.largeTitle)
                .padding()

            Text("This sheet was presented from the top-most view controller!")
                .multilineTextAlignment(.center)
                .padding()

            Button("Dismiss") {
                dismiss()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }

    // Function to dismiss the sheet
    private func dismiss() {
        if let topController = UIViewController.topMostViewController() {
            topController.dismiss(animated: true)
        }
    }
}


// Shake gesture for SwiftUI
// From: https://www.hackingwithswift.com/quick-start/swiftui/how-to-detect-shake-gestures

// The notification we'll send when a shake gesture happens.
extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name(rawValue: "deviceDidShakeNotification")
}

//  Override the default behavior of shake gestures to send our notification instead.
extension UIWindow {
    // swiftlint:disable:next override_in_extension
    override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}

// A view modifier that detects shaking and calls a function of our choosing.
struct DeviceShakeViewModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
                action()
            }
    }
}

// A View extension to make the modifier easier to use.
extension View {
    public func onShake(perform action: @escaping () -> Void) -> some View {
        self.modifier(DeviceShakeViewModifier(action: action))
    }
}

