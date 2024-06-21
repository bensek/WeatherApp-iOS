//
//  ContentView.swift
//  WeatherApp
//
//  Created by Ben Sekyondwa on 21/06/2024.
//

import SwiftUI
import Alamofire

struct ContentView: View {
    
    let blueSky = Color.init(red: 135/255, green: 206/255, blue: 235/255)
    let greySky = Color.init(red: 47/255, green: 79/255, blue: 79/255)
    
    @State private var results = [ForecastDay]()
    @State var backgroundColor = Color.init(red: 135/255, green: 206/255, blue: 235/255)
    @State var weatherEmoji = "☀️"
    @State var currentTemp = 0
    @State var conditionText = "Slightly Overcast"
    @State var cityName = "Toronto"
    @State var loading = true
    
    var body: some View {
        VStack {
            Text("\(cityName)")
                .font(.system(size: 35))
                .foregroundStyle(.white)
                .bold()
            
            Text("\(Date().formatted(date: .complete, time: .omitted))")
                .foregroundStyle(.white)
                .font(.system(size: 18))
            
            Text(weatherEmoji)
                .font(.system(size: 180))
                .shadow(radius: 75)
            Text("\(currentTemp)°C")
                .font(.system(size: 70))
                .foregroundStyle(.white)
                .bold()
            Text("\(conditionText)")
                .font(.system(size: 22))
                .foregroundStyle(.white)
                .bold()
            Spacer()
            Spacer()
            Spacer()
            List(results) { forecast in
                HStack(alignment: .center, spacing: nil) {
                    Text("\(getShortDate(epoch: forecast.date_epoch))")
                        .frame(maxWidth: 50, alignment: .leading)
                        .bold()
                    Text("\(getWeatherEmoji(text: forecast.day.condition.text))")
                        .frame(maxWidth: 30, alignment: .leading)
                    Text("\(Int(forecast.day.avgtemp_c))°C")
                        .frame(maxWidth: 50, alignment: .leading)
                    Spacer()
                    Text("\(forecast.day.condition.text)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .listRowBackground(Color.white.blur(radius: 75).opacity(0.5))
            }
            .padding(.vertical, 0)
            .scrollContentBackground(.hidden)
            .preferredColorScheme(.dark)
            
            Text("Data supplied by Weather API")
                .foregroundStyle(.white)
                .font(.system(size: 14))
        
        }
        .background(backgroundColor)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .task {
            await fetchWeather()
        }
    }
    
    func fetchWeather() async {
        let request = AF.request("https://api.weatherapi.com/v1/forecast.json?key=633655ce309a4106b37100620242106&q=London&days=3&aqi=no&alerts=no")
        request.responseDecodable(of: Weather.self) { response in
            switch response.result {
            case .success(let weather):
                //dump(weather)
                cityName = weather.location.name
                results = weather.forecast.forecastday
                currentTemp = Int(results[0].day.avgtemp_c)
                backgroundColor = getBackgroundColor(text: results[0].day.condition.text)
                weatherEmoji = getWeatherEmoji(text: results[0].day.condition.text)
                conditionText = results[0].day.condition.text
                loading = false
                
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    
    func getWeatherEmoji(text: String) -> String {
        var weatherEmoji = "☀️"
        let conditionText = text.lowercased()
        if conditionText.contains("snow") ||
            conditionText.contains("blizzard") {
            weatherEmoji = "🌨️"
        } else if conditionText.contains("rain") {
            weatherEmoji = "🌧️"
        } else if conditionText.contains("partly cloudy") {
            weatherEmoji = "🌤️"
        } else if conditionText.contains("cloudy") ||
                    conditionText.contains("overcast") {
            weatherEmoji = "☁️"
        } else if conditionText.contains("clear") ||
                    conditionText.contains("sunny") {
            weatherEmoji = "☀️"
        }
        return weatherEmoji
    }
    
    func getBackgroundColor(text: String) -> Color {
        var backgroundColor = blueSky
        let conditionText = text.lowercased()
        if !(conditionText.contains("clear") ||
            conditionText.contains("sunny")) {
            backgroundColor = greySky
        }
        return backgroundColor
    }
    
    func  getShortDate(epoch: Int) -> String {
        return Date(timeIntervalSince1970: TimeInterval(epoch))
            .formatted(Date.FormatStyle()
            .weekday(.abbreviated))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
