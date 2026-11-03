import UIKit

enum Theme {
    static let accent = UIColor(red: 0.165, green: 0.427, blue: 0.851, alpha: 1)
    static let navy = UIColor(red: 0.10, green: 0.18, blue: 0.29, alpha: 1)
    static let textPrimary = UIColor(red: 0.12, green: 0.14, blue: 0.16, alpha: 1)
    static let textSecondary = UIColor(red: 0.34, green: 0.38, blue: 0.42, alpha: 1)
    static let border = UIColor(red: 0.90, green: 0.91, blue: 0.92, alpha: 1)
    static let surface = UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1)
    static let selectedFill = UIColor(red: 0.918, green: 0.945, blue: 0.992, alpha: 1)
    static let star = UIColor(red: 0.96, green: 0.65, blue: 0.14, alpha: 1)

    static func color(hex: UInt32) -> UIColor {
        UIColor(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }

    static func styleNavigationBar(_ appearance: UINavigationBarAppearance = UINavigationBarAppearance()) -> UINavigationBarAppearance {
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = navy
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        return appearance
    }
}

extension UIView {
    func pinEdges(to other: UIView, insets: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: other.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: other.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: other.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: other.bottomAnchor, constant: -insets.bottom)
        ])
    }
}

extension UIViewController {
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
