//
//  RouteDataModel.swift
//  Dubki
//
//  Created by Alexander Morenko on 30.10.15.
//  Copyright © 2015 Alexander Morenko. All rights reserved.
//

import UIKit

// Singleton Class
class RouteDataModel: NSObject {
    
    static let sharedInstance = RouteDataModel()

    var campuses: NSArray?
    
    var fromCampus: Dictionary<String, AnyObject>?
    var toCampus: Dictionary<String, AnyObject>?
    var when: NSDate?
    var route = [
        ["title": "Дубки → Строгино", "detail": "отправление: 09:00 → прибытие: 10:18"],
        ["title": "🚌 Автобус", "detail": "Дубки (09:10) → Одинцово (09:25)"],
        ["title": "🚊 Электричка", "detail": "Кубинка 1 - Москва (Белорусский вокзал) (09:31 → 09:47)\nОстановки: везде\nВыходите на станции: Кунцево", "url": "http://rasp.yandex.ru/"],
        ["title": "🚇 Метро", "detail":"Кунцевская (09:57) → Строгино (10:12)"],
        ["title": "🚶 Пешком", "detail":"Примерно 6 минут"]
    ]
    
    override init() {
        super.init()
        
        // load array of campuses from resource
        let campusesPath = NSBundle.mainBundle().pathForResource("Campuses", ofType: "plist")
        campuses = NSArray(contentsOfFile: campusesPath!)
        //print(campuses?.count)
        
    }
    
    func routeSetParameter(from: Int, to: Int, when: NSDate) {
        
        self.fromCampus = campuses![from - 1] as? Dictionary<String, AnyObject>
        self.toCampus = campuses![to - 1] as? Dictionary<String, AnyObject>
        self.when = when
        
        if from == 1 {
            route = [
                ["title": "Дубки → Строгино", "detail": "отправление: 09:00 | прибытие: 10:18"],
                ["title": "🚌 Автобус", "detail": "Дубки (09:10) → Одинцово (09:25)"],
                ["title": "🚊 Электричка", "detail": "Кубинка 1 - Москва (Белорусский вокзал) (09:31 → 09:47)\nОстановки: везде\nВыходите на станции: Кунцево", "url": "http://rasp.yandex.ru/"],
                ["title": "🚇 Метро", "detail":"Кунцевская (09:57) → Строгино (10:12)"],
                ["title": "🚶 Пешком", "detail":"Примерно 6 минут"]
            ]
        } else {
            route = [
                ["title": "Строгино → Дубки", "detail": "отправление: 15:31 | прибытие: 17:35"],
                ["title": "🚶 Пешком", "detail": "Примерно 6 минут"],
                ["title": "🚇 Метро", "detail": "Строгино (15:37) → Кунцевская (15:52)"],
                ["title": "🚊 Электричка", "detail": "Москва (Белорусский вокзал) - Можайск (16:27 → 16:39)\nОстановки: Рабочий Посёлок, Сетунь, Одинцово\nВыходите на станции: Одинцово", "url": "http://rasp.yandex.ru/"],
                ["title": "🚌 Автобус", "detail": "динцово (17:20) → Дубки (17:35)"]
            ]
        }
    }
}
