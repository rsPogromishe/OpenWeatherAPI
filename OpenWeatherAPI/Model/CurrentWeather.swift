//
//  CurrentWeather.swift
//  OpenWeatherAPI
//
//  Created by Снытин Ростислав on 26.06.2022.
//

import Foundation

struct CurrentWeather: Codable {
    let cityName: String
    let temperatureDouble: Double
    let feelsLikeTemperatureDouble: Double
    let conditionCode: Int

    var temperature: String {
        return String(format: "%.0f", temperatureDouble)
    }
    var feelsLikeTemperature: String {
        return String(format: "%.0f", feelsLikeTemperatureDouble)
    }
    var systemIconNameString: String {
        switch conditionCode {
        case 200...232: return "cloud.bolt.rain.fill"
        case 300...321: return "cloud.drizzle.fill"
        case 500...531: return "cloud.rain.fill"
        case 600...622: return "cloud.show.fill"
        case 701...781: return "smoke.fill"
        case 800: return "sun.min.fill"
        case 801...804: return "cloud.fill"
        default: return "nosign"
        }
    }

    init?(currentWeatherData: CurrentWeatherData) {
        cityName = currentWeatherData.name
        temperatureDouble = currentWeatherData.main.temp
        feelsLikeTemperatureDouble = currentWeatherData.main.feelsLike
        conditionCode = currentWeatherData.weather.first?.id ?? 0
    }
}
