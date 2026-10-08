import UIKit

/// Full-screen gradient background that can cross-fade between colour sets.
final class GradientView: UIView {

    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        gradientLayer.startPoint = CGPoint(x: 0.2, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.8, y: 1)
        layer.addSublayer(gradientLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not used; views are created in code")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    func apply(colors: [UIColor], animated: Bool) {
        let newColors = colors.map { $0.cgColor }
        if animated {
            let animation = CABasicAnimation(keyPath: "colors")
            animation.fromValue = gradientLayer.colors
            animation.toValue = newColors
            animation.duration = 0.6
            gradientLayer.add(animation, forKey: "colorChange")
        }
        gradientLayer.colors = newColors
    }
}
