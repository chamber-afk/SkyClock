import UIKit

final class MainViewController: UIViewController {

    // MARK: - Dependencies

    private let viewModel: WeatherViewModel

    // MARK: - Views

    private let backgroundView = GradientView()
    private let scrollView = UIScrollView()
    private let refreshControl = UIRefreshControl()
    private let contentStack = UIStackView()
    private let headerStack = UIStackView()
    private let titleLabel = UILabel.make(font: .scaled(.largeTitle, size: 32, weight: .bold), alignment: .left)
    private let unitControl = UISegmentedControl(items: ["°C", "°F"])
    private let searchBar = UISearchBar()
    private let chipsView = ChipsView()
    private let spinner = UIActivityIndicatorView(style: .large)
    private let messageLabel = UILabel.make(font: .preferredFont(forTextStyle: .body),
                                            color: UIColor.white.withAlphaComponent(0.9),
                                            lines: 0)
    private let weatherCard = WeatherCardView()

    private var currentWeather: Weather?

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - Init

    init(viewModel: WeatherViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not used; the UI is built in code")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark // The gradients are always dark enough for white text.
        setUpHierarchy()
        setUpConstraints()
        configureControls()
        bindViewModel()

        backgroundView.apply(colors: WeatherTheme.clear.gradientColors(isDaytime: true), animated: false)
        render(viewModel.state)
        viewModel.loadLastCity()
    }

    // MARK: - Setup

    private func setUpHierarchy() {
        view.addSubview(backgroundView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.spacing = 12
        headerStack.addArrangedSubview(titleLabel)
        headerStack.addArrangedSubview(unitControl)

        contentStack.axis = .vertical
        contentStack.spacing = 16
        [headerStack, searchBar, chipsView, spinner, messageLabel, weatherCard].forEach {
            contentStack.addArrangedSubview($0)
        }

        [backgroundView, scrollView, contentStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40),

            unitControl.widthAnchor.constraint(equalToConstant: 100)
        ])
    }

    private func configureControls() {
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        scrollView.contentInsetAdjustmentBehavior = .always
        scrollView.refreshControl = refreshControl

        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)

        titleLabel.text = "SkyClock"
        titleLabel.accessibilityTraits = .header

        unitControl.selectedSegmentIndex = viewModel.useFahrenheit ? 1 : 0
        unitControl.selectedSegmentTintColor = UIColor.white.withAlphaComponent(0.35)
        unitControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        unitControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        unitControl.accessibilityLabel = "Temperature unit"
        unitControl.addTarget(self, action: #selector(unitChanged), for: .valueChanged)

        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .words
        searchBar.returnKeyType = .search
        searchBar.accessibilityLabel = "Search city"
        searchBar.searchTextField.textColor = .white
        searchBar.searchTextField.leftView?.tintColor = UIColor.white.withAlphaComponent(0.7)
        searchBar.searchTextField.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search city",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.6)]
        )

        spinner.color = .white
        spinner.hidesWhenStopped = true

        messageLabel.isHidden = true
        weatherCard.isHidden = true
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in self?.render(state) }
        viewModel.onFlagChange = { [weak self] image in self?.weatherCard.setFlag(image) }
        viewModel.onRecentsChange = { [weak self] cities in self?.chipsView.update(cities: cities) }

        chipsView.onSelect = { [weak self] city in self?.search(city: city) }
        chipsView.update(cities: viewModel.recentCities)
    }

    // MARK: - Rendering

    private func render(_ state: WeatherViewModel.State) {
        switch state {
        case .idle:
            spinner.stopAnimating()
            showMessage("Search for a city to see its weather and local time.")

        case .loading:
            showMessage(nil)
            if !refreshControl.isRefreshing { spinner.startAnimating() }

        case .loaded(let weather):
            finishLoading()
            showMessage(nil)
            show(weather)

        case .failed(let error):
            finishLoading()
            showMessage(error.localizedDescription)
            UIAccessibility.post(notification: .announcement, argument: error.localizedDescription)
        }
    }

    private func finishLoading() {
        spinner.stopAnimating()
        refreshControl.endRefreshing()
    }

    private func showMessage(_ text: String?) {
        messageLabel.text = text
        messageLabel.isHidden = (text == nil)
    }

    private func show(_ weather: Weather) {
        currentWeather = weather
        backgroundView.apply(colors: weather.theme.gradientColors(isDaytime: weather.isDaytime), animated: true)

        let display = viewModel.display(for: weather)
        if weatherCard.isHidden {
            weatherCard.configure(with: display)
            weatherCard.alpha = 0
            UIView.animate(withDuration: 0.4) {
                self.weatherCard.isHidden = false
                self.weatherCard.alpha = 1
            }
        } else {
            UIView.transition(with: weatherCard,
                              duration: 0.3,
                              options: .transitionCrossDissolve,
                              animations: { self.weatherCard.configure(with: display) })
        }
    }

    // MARK: - Actions

    private func search(city: String) {
        searchBar.resignFirstResponder()
        searchBar.text = nil
        viewModel.search(city: city)
    }

    @objc private func didPullToRefresh() {
        guard viewModel.currentCity != nil else {
            refreshControl.endRefreshing()
            return
        }
        viewModel.refresh()
    }

    @objc private func unitChanged() {
        viewModel.useFahrenheit = (unitControl.selectedSegmentIndex == 1)
        if let weather = currentWeather {
            weatherCard.configure(with: viewModel.display(for: weather))
        }
    }
}

// MARK: - UISearchBarDelegate

extension MainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        search(city: searchBar.text ?? "")
    }
}
