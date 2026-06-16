import Foundation
import RxSwift
import RxCocoa

public enum ChangePriceResult {
    
    case success
    case isNotGreaterThanZero
}

public enum States {
    
    case finishedWork(worker: WorkerType)
}

public class CarWashController {
    
    // MARK: -
    // MARK: Variables
    
    public weak var chief: Chief?
    public var workers: [Weak<WorkerType>] = []
    public let carWash: CarWash
    public let lock = NSRecursiveLock()
    
    var employmentLog: EmploymentLogProtocol
    let disposeBag = DisposeBag()
    
    // MARK: -
    // MARK: Initialization
    
    init(
        chief: Chief,
        washers: inout [Washer],
        accountants: inout [Accountant],
        log: EmploymentLogProtocol,
        carWash: CarWash
    )
    {
        self.carWash = carWash
        
        self.chief = chief
        self.chief?.workPlace = self.carWash
        
        self.employmentLog = log
        
        self.hire(workers: &accountants)
        self.hire(workers: &washers)
        self.appoint(subordinates: &washers)
        
        self.prepareObservingWashers()
        self.prepareObservingManagers()
    }
    
    // MARK: -
    // MARK: Public
    
    public func startWork(iterations: Int = 5, carsPerIteration: Int = 20) {
        guard iterations > 0, carsPerIteration > 0 else { return }
        guard let chief = self.chief else { return }

        let queue = DispatchQueue(label: "io.washing", attributes: .concurrent)

        for iteration in 1...iterations {
            print("\n--- Iteration \(iteration) ---")

            self.takeDirtyCars(count: carsPerIteration)

            self.workers
                .compactMap { $0.object as? Washer }
                .forEach { washer in
                    queue.async {
                        washer.search { car in
                            guard let car = car else { return }
                            washer.work(processable: car)
                        }
                    }
                }

            sleep(5)

            print("\nChief earned \(chief.money)\n")
        }
    }
    
    public func take(car: Car) {
        let car = Weak(object: car)
        
        self.carWash.cars.mutate({ cars in
            cars.append(car)
        })
    }
    
    public func remove(car: Car) {
        self.carWash.cars.mutate({ cars in
            cars.removeAll(where: { $0.object == car })
        })
    }
    
    public func hire<Action: MoneyContainable, WorkerType: Worker<Action>>(
        workers: inout [WorkerType]
    ) {
        workers.forEach { element in
            element.workPlace = self.carWash
        
            self.workers.append(Weak(object: element))
            
            if let accountant = element as? Accountant {
                self.employmentLog.add(supervizors: [accountant])
            }
        }
    }
    
    public func fire(workers: [WorkerType]) {
        workers.forEach { worker in
            self.workers.removeAll { worker in
                workers.contains { worker.object?.id == $0.id }
            }
            self.employmentLog.remove(worker: worker)
        }
    }
    
    public func change(literPrice: Float) -> ChangePriceResult {
        let isPositive = literPrice > 0

        if isPositive {
            self.carWash.priceWaterLiter = literPrice
        }
        
        return isPositive ? .success : .isNotGreaterThanZero
    }
    
    public func appoint(subordinates: inout [Washer]) {
        self.employmentLog.appoint(subordinates:  &subordinates)
    }
    
    // MARK: -
    // MARK: Private
    
    private func prepareObservingWashers() {
        var washers = self.workers.compactMap { $0.object as? Washer }
        
        washers.forEach {
            $0.carCleanableStatesHandler.bind { washer in
                self.lock.lock()
                defer { self.lock.unlock() }

                switch washer {
                case .carServiced(car: let car, result: let result):
                    self.washerStatesHandling(car: car, result: result)
                }
            }
        }
    }
    
    private func prepareObservingManagers() {
        var managers: [WorkNotificable?] = self.workers.map { $0.object as? Accountant }
        managers.append(self.chief)
        
        managers
            .compactMap { $0 }
            .forEach {
                $0.managerStatesHandler.bind { manager in
                self.lock.lock()
                defer { self.lock.unlock() }

                switch manager {
                case .finishedWork(worker: let subordinate):
                    self.startWorkSupervisor(of: subordinate)
                }
            }
            .disposed(by: self.disposeBag)
        }
}
    
    private func washerStatesHandling(car: Car, result: CleanResult) {
        switch result {
            case .noNeedToClean:
                print("Car \(car.brand) is clean .- .")

            case .notEnoughMoney:
                print("\(car.brand) doesnt have enough money!")

            case .success:
                print("\(car.brand) was washed")
        }
        self.remove(car: car)
    }
    
    private func startWorkSupervisor(of subordinate: WorkerType) {
        let supervisor = self.employmentLog.getSupervizor(subordinate: subordinate)
        
        if let chief = supervisor as? Chief,
           let subordinate = subordinate as? Accountant
        {
            chief.subordinatesQueue.sync {
                chief.work(processable: subordinate)
            }
        }
        if let accountant = supervisor as? Accountant,
           let subordinate = subordinate as? Washer
        {
            accountant.subordinatesQueue.sync {
                accountant.work(processable: subordinate)
            }
        }
        
    }
    
    private func takeDirtyCars(count: Int) {
        let cars = Car.random(count: count)
        
        cars.forEach { $0.drive() }

        cars
            .filter { $0.isDirty }
            .forEach { self.take(car: $0)}
    }
    
    
}
