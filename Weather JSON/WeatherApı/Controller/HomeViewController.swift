//
//  ViewController.swift
//  WeatherApı
//
//  Created by Doğukan Varılmaz on 2.05.2023.
//

import UIKit
import CoreLocation

class HomeViewController: UIViewController {
    //MARK: - Properties
    var viewModel: WeatherViewModel? {
        didSet{ configure() }
    }
    private let backgroundImageView = UIImageView()
    private let mainStackView = UIStackView()
    private let searchStackView = SearchStackView()
  
    private let statusImageView = UIImageView()
    private let temperatureLabel = UILabel()
    private let cityLabel = UILabel()
    private let locationManager = CLLocationManager()
    private let service = WeatherService()
    
    //MARK: - Properties
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
        configureLocation()
        backgroundImageView.contentMode = .scaleAspectFill
    }


}
//MARK: - Helpers
extension HomeViewController{
    private func style(){
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.contentMode = .scaleAspectFit
        backgroundImageView.image = UIImage(named: "Image")
        
        
     
        searchStackView.translatesAutoresizingMaskIntoConstraints = false
        searchStackView.spacing = 8
        searchStackView.axis = .horizontal
        searchStackView.delegate = self
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.spacing = 10
        mainStackView.axis = .vertical
        mainStackView.alignment = .trailing
        
        statusImageView.translatesAutoresizingMaskIntoConstraints = false
        statusImageView.image = UIImage(named: "sun.max")
        statusImageView.tintColor = .label
        
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.font = UIFont.systemFont(ofSize: 80)
        temperatureLabel.attributedText = attributedText(with: "15")
        
        cityLabel.translatesAutoresizingMaskIntoConstraints = false
        cityLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        cityLabel.text = "Ankara"
    }
    private func layout(){
        view.addSubview(backgroundImageView)
        view.addSubview(mainStackView)
        mainStackView.addArrangedSubview(searchStackView)
      
        mainStackView.addArrangedSubview(statusImageView)
        mainStackView.addArrangedSubview(temperatureLabel)
        mainStackView.addArrangedSubview(cityLabel)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: backgroundImageView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: backgroundImageView.bottomAnchor),
            
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 8),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            view.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor,constant: 8),
            
            searchStackView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor),
            
            
            statusImageView.heightAnchor.constraint(equalToConstant: 85),
            statusImageView.widthAnchor.constraint(equalToConstant: 85),
        ])
    }
    
    private func attributedText(with text: String) -> NSMutableAttributedString {
        let attributedText = NSMutableAttributedString(string: text,attributes: [.foregroundColor : UIColor.label,.font: UIFont.boldSystemFont(ofSize: 90)])
        attributedText.append(NSAttributedString(string: "°C",attributes: [.font: UIFont.systemFont(ofSize: 50)]))
        return attributedText
    }
    
    private func configureLocation(){
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
    }
    
    private func configure(){
        guard let viewModel = self.viewModel else {return}
        self.cityLabel.text = viewModel.cityName
        self.temperatureLabel.attributedText = attributedText(with: viewModel.temperatureString!)
        self.statusImageView.image = UIImage(systemName: viewModel.statusName)
    }
    
    private func showErrorAlert(forErrorMessage message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert,animated: true)
    }
    
    private func parseError(error: ServiceError) {
        switch error {
            case .serverError:
                showErrorAlert(forErrorMessage: error.rawValue)
            case .decodingError:
                showErrorAlert(forErrorMessage: error.rawValue)
        }
    }
}

extension HomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        locationManager.stopUpdatingLocation()
        self.service.fetchWeatherLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) { result  in
            switch  result {
                case .success(let result):
                    self.viewModel = WeatherViewModel(weatherModel: result)
                case .failure(let error):
                    self.parseError(error: error)
            }
        }
        
    }
}

extension HomeViewController: SearchStackViewDelegate {
    func updatingLocation(_ searchStackView: SearchStackView) {
        self.locationManager.startUpdatingLocation()
    }
    
    func didFailWithError(_ searchStackView: SearchStackView, error: ServiceError) {
        parseError(error: error)
    }
    
    func didFetchWeather(_ searchStackView: SearchStackView, weatherModel: WeatherModel) {
        self.viewModel = WeatherViewModel(weatherModel: weatherModel)
    }
    
    
}
