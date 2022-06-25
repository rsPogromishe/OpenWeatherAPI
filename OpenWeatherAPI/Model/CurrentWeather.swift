//
//  CurrentWeather.swift
//  OpenWeatherAPI
//
//  Created by Снытин Ростислав on 26.06.2022.
//

import Foundation

struct CurrentWeather {
    var cityName: String
    var temperature: String
    var feelsLikeTemperature: String
    let conditionCode: Int
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
}
