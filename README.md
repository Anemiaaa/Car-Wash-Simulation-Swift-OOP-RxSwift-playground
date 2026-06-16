# Car Wash Simulation — Swift Playground

A Swift playground that simulates the business logic of a car wash service.

The project demonstrates object-oriented programming, protocol-oriented design, RxSwift event handling, weak references, and basic concurrency with `DispatchQueue`.

## Overview

The simulation includes several business entities:

* `CarWash` — stores cars and service settings
* `Car` — represents a customer car
* `Washer` — searches for dirty cars and washes them
* `Accountant` — supervises washers and handles payments
* `Chief` — supervises accountants and receives business income
* `EmploymentLog` — manages worker hierarchy and supervisor relationships
* `CarWashController` — coordinates the full workflow

The app creates random cars and workers, assigns supervisors, processes dirty cars, and prints the result of each washing cycle.

## Tech Stack

* Swift
* RxSwift
* RxCocoa
* Xcode Playground
* CocoaPods
* DispatchQueue
* Protocol-Oriented Programming
* Object-Oriented Programming

## Features

* Car wash business logic simulation
* Random generation of cars and workers
* Worker hierarchy: chief → accountants → washers
* Car cleaning flow
* Money/payment handling
* Supervisor notifications
* Event handling with RxSwift
* Thread-safe operations using locks
* Concurrent washing process using `DispatchQueue`

## Project Structure

```text
rxCarWash/
├── CarWash.playground/
│   ├── Contents.swift
│   └── Sources/
│       ├── Classes/
│       ├── Model/
│       ├── Protocols/
│       └── CarWashController.swift
├── Podfile
└── Podfile.lock
```

## How to Run

This project is designed to run on macOS with Xcode.

1. Clone the repository:

```bash
git clone https://github.com/Anemiaaa/Car-wash.git
```

2. Open the project folder:

```bash
cd Car-wash/rxCarWash
```

3. Install dependencies:

```bash
pod install
```

4. Open `rxCarWash.xcworkspace` in Xcode.

5. Run `CarWash.playground`.

## Note

The project cannot be run directly on Windows because it uses Xcode Playground and CocoaPods for an iOS/macOS development environment.

## What I Practiced

This project was created to practice:

* Swift classes and protocols
* Generic functions
* Weak references
* Business logic modeling
* RxSwift bindings
* Multithreading basics
* Separation of models, protocols, and controller logic

## Possible Improvements

* Add unit tests for worker and payment logic
* Improve naming consistency
* Add a console output example
* Convert the playground into a small iOS app with UI
