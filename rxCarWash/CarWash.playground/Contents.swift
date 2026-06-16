import Foundation

import PlaygroundSupport

let chief = Chief()
var log = EmploymentLog(chief: chief)
var carWash = CarWash(priceWaterLiter: 5.0)

var accountants: [Accountant] = (1...7).map { _ in
    Accountant.random()
}

var washers: [Washer] = (1...20).map { _ in
    Washer.random()
}

let controller = CarWashController(
    chief: chief,
    washers: &washers,
    accountants: &accountants,
    log: log,
    carWash: carWash
)
controller.startWork(iterations: 3, carsPerIteration: 10)
//print("smt")
