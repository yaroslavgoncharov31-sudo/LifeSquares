import Testing
@testable import TimeCore
internal import Foundation

struct ForecastTests {
    @Test(arguments: [
        (0, 6, 30 ,124, Forecast.notEnoughData),
        (0, 0, 30, 124, Forecast.notEnoughData),
        (6, 6, 2, 124, Forecast.completed),
        (1, 6, 30, 124, Forecast.projected(workingDaysNeeded: 150)),
        (2, 6, 30, 124, Forecast.projected(workingDaysNeeded: 60)),
        (4, 6, 25, 124, Forecast.projected(workingDaysNeeded: 13)),
        (1, 6, 20, 100, Forecast.projected(workingDaysNeeded: 100)),
        (1, 6, 19, 100, Forecast.notEnoughData),
        (1, 6, 0, 0, Forecast.notEnoughData),
        (7, 6, 10, 100, Forecast.completed)
    ])
    func forecast_returnsCorrectForecast(closed: Int, total: Int, elapsedAvailable: Int, totalAvailable: Int, expected: Forecast) {
        let forecast = Forecast.make(closed: closed, total: total, totalAvailable: totalAvailable, elapsedAvailable: elapsedAvailable)

        #expect(forecast == expected)
    }
}
