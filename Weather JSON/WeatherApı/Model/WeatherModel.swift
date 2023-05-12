//
//  WeatherModel.swift
//  WeatherApı
//
//  Created by Doğukan Varılmaz on 3.05.2023.
//

import Foundation


struct WeatherModel: Codable  {
    let name: String
    let main: Main
    let weather: [Weather]
}

struct Main: Codable {
    let temp: Double
}

struct Weather: Codable {
    let description: String
    let id: Int
}
