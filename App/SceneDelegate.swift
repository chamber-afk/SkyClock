import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let splash = SplashViewController()
        splash.onGetStarted = { [weak self] in
            self?.showMainScreen()
        }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = splash
        window.makeKeyAndVisible()
        self.window = window
    }

    private func showMainScreen() {
        guard let window else { return }
        let main = MainViewController(viewModel: WeatherViewModel())
        UIView.transition(with: window,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: { window.rootViewController = main })
    }
}
