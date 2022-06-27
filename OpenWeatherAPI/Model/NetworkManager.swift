//
//  NetworkManager.swift
//  OpenWeatherAPI
//
//  Created by Снытин Ростислав on 27.06.2022.
//

import Foundation
import CoreLocation

enum NetworkError {
    case failedURL
    case parsingError
    case emptyData
}

class NetworkManager {
    enum RequestType {
        case cityName(city: String)
        case coordinate(latitude: CLLocationDegrees, longitude: CLLocationDegrees)
    }

    func fetchData(
        requestType: RequestType,
        onCompletion: @escaping ((CurrentWeather) -> Void),
        onError: @escaping ((NetworkError) -> Void)
    ) {
        guard let url = createURLcomponents(requestType: requestType) else {
            onError(.failedURL)
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                do {
                    if let note = try self.parseJSON(withData: data) {
                        onCompletion(note)
                    }
                } catch {
                    onError(.parsingError)
                }
            } else {
                onError(.emptyData)
            }
        }.resume()
    }

    private func createURLcomponents(requestType: RequestType) -> URL? {
        var urlComponents = URLComponents()

        urlComponents.scheme = "https"
        urlComponents.host = "api.openweathermap.org"
        urlComponents.path = "/data/2.5/weather"
        switch requestType {
        case .cityName(let city):
            urlComponents.queryItems = [
                URLQueryItem(name: "q", value: city),
                URLQueryItem(name: "appid", value: Constant.keyAPI),
                URLQueryItem(name: "units", value: "metric")
            ]
        case .coordinate(let latitude, let longitude):
            urlComponents.queryItems = [
                URLQueryItem(name: "lat", value: "\(latitude)"),
                URLQueryItem(name: "lon", value: "\(longitude)"),
                URLQueryItem(name: "appid", value: Constant.keyAPI),
                URLQueryItem(name: "units", value: "metric")
            ]
        }
        return urlComponents.url
    }

    private func parseJSON(withData data: Data) throws -> CurrentWeather? {
        let decoder = JSONDecoder()
        let noteData = try decoder.decode(CurrentWeatherData.self, from: data)
        guard let currentWeather = CurrentWeather(currentWeatherData: noteData) else { return nil }
        return currentWeather
    }
}
