//
//  ViewController.swift
//  OpenWeatherAPI
//
//  Created by Снытин Ростислав on 25.06.2022.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController {
    private let viewModel = ViewModel()
    lazy var locationManager: CLLocationManager = {
        let location = CLLocationManager()
        location.delegate = self
        location.desiredAccuracy = kCLLocationAccuracyKilometer
        location.requestWhenInUseAuthorization()
        return location
    }()

    private let backgroundImageView = UIImageView()
    private let weatherIconImageView = UIImageView()
    private let temperatureLabel = UILabel()
    private let feelsLikeLabel = UILabel()
    private let cityLabel = UILabel()
    private let searchButton = UIButton()
    private let locationButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundImage()
        setupSearchView()
        setupWeatherView()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
        }
    }

    @objc func searchButtonTapped() {
        presentSearchAlertController { city in
            self.viewModel.fetchWeather(requestType: .cityName(city: city)) { [weak self] weather in
                guard let self = self else { return }
                self.updateInterface(weather: weather)
            }
        }
    }

    @objc func locationButtonTapped() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
        } else {
            presentErrorAlertController()
        }
    }

    private func updateInterface(weather: CurrentWeather) {
        DispatchQueue.main.async {
            self.cityLabel.text = weather.cityName
            self.weatherIconImageView.image = UIImage(systemName: weather.systemIconNameString)
            self.temperatureLabel.text = "\(String(describing: weather.temperature))°C"
            self.feelsLikeLabel.text = "Feels like \(String(describing: weather.feelsLikeTemperature))°C"
        }
    }
}

// MARK: Setup UI

extension MainViewController {
    private func setupBackgroundImage() {
        self.view.addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundImageView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        backgroundImageView.image = UIImage(named: Constant.imageSet)
    }

    private func setupSearchView() {
        self.view.addSubview(searchButton)
        self.view.addSubview(cityLabel)
        self.view.addSubview(locationButton)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        cityLabel.translatesAutoresizingMaskIntoConstraints = false
        locationButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            searchButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            searchButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            searchButton.widthAnchor.constraint(equalToConstant: 40),
            searchButton.heightAnchor.constraint(equalToConstant: 40),

            cityLabel.rightAnchor.constraint(equalTo: searchButton.leftAnchor, constant: -8),
            cityLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            cityLabel.centerYAnchor.constraint(equalTo: searchButton.centerYAnchor),

            locationButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            locationButton.bottomAnchor.constraint(equalTo: searchButton.topAnchor, constant: -20),
            locationButton.widthAnchor.constraint(equalToConstant: 40),
            locationButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        searchButton.setImage(UIImage(systemName: Constant.searchImageName), for: .normal)
        searchButton.contentVerticalAlignment = .fill
        searchButton.contentHorizontalAlignment = .fill
        searchButton.tintColor = UIColor(named: Constant.colorSet)
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)

        cityLabel.textColor = UIColor(named: Constant.colorSet)
        cityLabel.font = .systemFont(ofSize: 28, weight: .medium)

        locationButton.setImage(UIImage(systemName: Constant.locationImageName), for: .normal)
        locationButton.contentVerticalAlignment = .fill
        locationButton.contentHorizontalAlignment = .fill
        locationButton.tintColor = UIColor(named: Constant.colorSet)
    }

    private func setupWeatherView() {
        self.view.addSubview(weatherIconImageView)
        self.view.addSubview(temperatureLabel)
        self.view.addSubview(feelsLikeLabel)
        weatherIconImageView.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        feelsLikeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            weatherIconImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            weatherIconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            weatherIconImageView.widthAnchor.constraint(equalToConstant: 170),
            weatherIconImageView.heightAnchor.constraint(equalToConstant: 170),

            temperatureLabel.topAnchor.constraint(equalTo: weatherIconImageView.bottomAnchor),
            temperatureLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            feelsLikeLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor),
            feelsLikeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        weatherIconImageView.tintColor = UIColor(named: Constant.colorSet)
        weatherIconImageView.contentMode = .scaleAspectFit
        weatherIconImageView.image = UIImage(systemName: Constant.errorImageName)

        temperatureLabel.font = .systemFont(ofSize: 70, weight: .medium)
        temperatureLabel.textColor = UIColor(named: Constant.colorSet)
        temperatureLabel.text = "--°C"

        feelsLikeLabel.font = .systemFont(ofSize: 16, weight: .medium)
        feelsLikeLabel.textColor = UIColor(named: Constant.colorSet)
        feelsLikeLabel.text = "Feels like --°C"
    }

    private func presentSearchAlertController(completionHandler: @escaping (String) -> Void) {
        let alertController = UIAlertController(title: "Enter city name", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            let cities = ["San Francisco", "Moscow", "Vienna", "London", "Rome"]
            textField.placeholder = cities.randomElement()
        }

        let search = UIAlertAction(title: "Search", style: .default) { _ in
            let textField = alertController.textFields?.first
            guard let cityName = textField?.text else { return }
            if cityName != "" {
                let city = cityName.split(separator: " ").joined(separator: "%20")
                completionHandler(city)
            }
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(search)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }

    private func presentErrorAlertController() {
        let alertController = UIAlertController(
            title: "Location services is off",
            message: "Please, enable location services in Settings",
            preferredStyle: .alert
        )

        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)

        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: CoreLocationDelegate

extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude

        viewModel.fetchWeather(requestType: .coordinate(latitude: latitude, longitude: longitude)) { weather in
            self.updateInterface(weather: weather)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
