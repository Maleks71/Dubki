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

    //var campuses: NSArray?
    let campuses = NSArray(contentsOfFile: NSBundle.mainBundle().pathForResource("Campuses", ofType: "plist")!)
    
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
        //let campusesPath = NSBundle.mainBundle().pathForResource("Campuses", ofType: "plist")
        //campuses = NSArray(contentsOfFile: campusesPath!)
        //print(campuses?.count)
        
    }
    
    func routeSetParameter(from: Int, to: Int, when: NSDate) {
        
        self.fromCampus = campuses![from - 1] as? Dictionary<String, AnyObject>
        self.toCampus = campuses![to - 1] as? Dictionary<String, AnyObject>
        self.when = when
        
        let bus = NSLocalizedString("Bus", comment: "") // "🚌 Автобус"
        let rail = NSLocalizedString("Rail", comment: "") // "🚊 Электричка"
        let subway = NSLocalizedString("Subway", comment: "") // "🚇 Метро"
        let onfoot = NSLocalizedString("OnFoot", comment: "") // "🚶 Пешком"

        if from == 1 {
            route = [
                ["title": "Дубки → Строгино", "detail": "отправление: 09:00 | прибытие: 10:18"],
                ["title": bus, "detail": "Дубки (09:10) → Одинцово (09:25)"],
                ["title": rail, "detail": "Кубинка 1 - Москва (Белорусский вокзал) (09:31 → 09:47)\nОстановки: везде\nВыходите на станции: Кунцево", "url": "http://rasp.yandex.ru/"],
                ["title": subway, "detail":"Кунцевская (09:57) → Строгино (10:12)"],
                ["title": onfoot, "detail":"Примерно 6 минут"]
            ]
        } else {
            route = [
                ["title": "Строгино → Дубки", "detail": "отправление: 15:31 | прибытие: 17:35"],
                ["title": onfoot, "detail": "Примерно 6 минут"],
                ["title": subway, "detail": "Строгино (15:37) → Кунцевская (15:52)"],
                ["title": rail, "detail": "Москва (Белорусский вокзал) - Можайск (16:27 → 16:39)\nОстановки: Рабочий Посёлок, Сетунь, Одинцово\nВыходите на станции: Одинцово", "url": "http://rasp.yandex.ru/"],
                ["title": bus, "detail": "динцово (17:20) → Дубки (17:35)"]
            ]
        }
    }
    
    // Subway Route Data (timedelta in minutes)
    let subwayData = [
        "Кунцевская": [
            "Строгино":  15,
            "Семёновская": 28,
            "Курская": 21,
            "Ленинский проспект" : 28
        ],
        "Белорусская": [
            "Аэропорт": 6,
            "Тверская": 4
        ],
        "Беговая": [
            "Текстильщики": 22,
            "Лубянка": 12,
            "Шаболовская": 20,
            "Кузнецкий мост": 9,
            "Павелецкая": 17,
            "Китай-город": 11
        ],
        "Славянский бульвар": [
            "Строгино":  18,
            "Семёновская": 25,
            "Курская": 18,
            "Ленинский проспект": 25,
            "Аэропорт": 26,
            "Текстильщики": 35,
            "Лубянка": 21,
            "Шаболовская": 22,
            "Кузнецкий мост": 22,
            "Тверская": 22
        ]
    ]
    let subwayCloses = "01:00"
    let subwayOpens = "05:50"

    func getSubwayData(from: String, to: String) -> Int {
        if let fromStation = subwayData[from] {
            if let result = fromStation[to] {
                return result
            }
        }
        if let toStation = subwayData[to] {
            if let result = toStation[from] {
                return result
            }
        }
        print("not fround subway data from: \(from) to: \(to)")
        return 0
    }
    
    func getNearestSubway(from: String, to: String, when: NSDate) -> Dictionary<String, AnyObject> {
        var result: Dictionary<String, AnyObject> = ["from": from, "to": to]
        
//        if subwayCloses <= when && when <= subwayOpens {
//            // subway is still closed
//            when = subwayOpens
//        }
        result["departure"] = when
        result["arrival"] = /*when +*/ getSubwayData(from, to: to)
        
        return result
    }

    // On Foot Data (timedelta in minutes)
    let onFootEduDeltas = [
        "aeroport": 14,
        "strogino": 6,
        "tekstilshiki": 10,
        "st_basmannaya": 16,
        "vavilova": 5,
        "myasnitskaya": 6,
        "izmailovo": 16,
        "shabolovskaya": 4,
        "petrovka": 6,
        "paveletskaya": 5,
        "ilyinka": 7,
        "trehsvyat_b": 13,
        "trehsvyat_m": 15,
        "hitra": 13,
        "gnezdo": 5
    ]
    
    let mapSources = [
        "aeroport": "9kfYmO7lbg2o_YuSTvZqiY9rCevo23cs",
        "strogino": "pMeBRyKZjz3PnQn4HCZKIlagbMIv2Bxp",
        "tekstilshiki": "IcVLk9vNC1afHy5ge05Ae07wahHXZZ7H",
        "st_basmannaya": "LwunOFh66TXk8NyRAgKpsssV0Gdy34pG",
        "vavilova": "_Cz-NprpRRfD15AECXvyxGQb5N7RY3xC",
        "myasnitskaya": "GGWd7qLfRklaR5KSQQpKFOiJT8RPFGO-",
        "izmailovo": "tTSwzei04UwodpOe5ThQSKwo47ZiR8aO",
        "shabolovskaya": "0enMIqcJ_dLy8ShEHN34Lu-4XBAHsrno",
        "petrovka": "pSiE6gI2ftRfAGBDauSW0G0H2o9R726u",
        "paveletskaya": "1SimW8pYfuzER0tbTEYFs1RFaNUFnhh-",
        "ilyinka": "7UEkPE7kT0Bhb4rOzDbk2O57LdWBE8Lq",
        "trehsvyat_b": "_WWkurGGUbabsiPE9xgdLP_iJ61vbJrZ",
        "trehsvyat_m": "jBGwqmV8V-JjFzbG2M_13sGlAUVqug-9",
        "hitra": "j1cHqL5k2jw_MK31dlBLEwPPPmj72NNg",
        "gnezdo": "_a_UjKz_rMbmf2l_mWtsRUjlaqlRySIS"
    ]
    
    func formMapUrl(edu: String, type: String = "img") -> String? {
        if type == "img" {
            return "https://api-maps.yandex.ru/services/constructor/1.0/static/?sid=" + mapSources[edu]!
        } else if type == "script" {
            return "https://api-maps.yandex.ru/services/constructor/1.0/js/?sid=" + mapSources[edu]!
        }
        return nil
    }
    
    func getNearestOnFoot(edu: String, when: NSDate) -> Dictionary<String, AnyObject> {
        var result: Dictionary<String, AnyObject> = ["departure": when]
        result["arrival"] = when /*+ onFootEduDeltas[edu]*/
        result["time"] = onFootEduDeltas[edu]
        result["mapsrc"] = formMapUrl(edu)
        
        return result
    }
    
    // dormitory
    let dorms = [
        "dubki": "Дубки",
    ]
    
    // campus
    let edus = [
        "aeroport": "Кочновский проезд (метро Аэропорт)",
        "strogino": "Строгино",
        "myasnitskaya": "Мясницкая (метро Лубянка)",
        "vavilova": "Вавилова (метро Ленинский проспект)",
        "izmailovo": "Кирпичная улица (метро Семёновская)",
        "tekstilshiki": "Текстильщики",
        "st_basmannaya": "Старая Басманная",
        "shabolovskaya": "Шаболовская",
        "petrovka": "Петровка (метро Кузнецкий мост)",
        "paveletskaya": "Малая Пионерская (метро Павелецкая)",
        "ilyinka": "Ильинка (метро Китай-город)",
        "trehsvyat_b": "Большой Трёхсвятительский переулок (метро Китай-город)",
        "trehsvyat_m": "Малый Трёхсвятительский переулок (метро Китай-город)",
        "hitra": "Хитровский переулок (метро Китай-город)",
        "gnezdo": "Малый Гнездниковский переулок (метро Тверская)"
    ]
    
    // maps edus to preferred stations
    let prefStations = [
        "aeroport": "Белорусская",
        "strogino": "Кунцево",
        "tekstilshiki": "Беговая",
        "st_basmannaya": "Кунцево",
        "vavilova": "Кунцево",
        "myasnitskaya": "Беговая",
        "izmailovo": "Кунцево",
        "shabolovskaya": "Беговая",
        "petrovka": "Беговая",
        "paveletskaya":"Беговая",
        "ilyinka": "Беговая",
        "trehsvyat_b": "Беговая",
        "trehsvyat_m": "Беговая",
        "hitra": "Беговая",
        "gnezdo": "Белорусская"
    ]
    
    // delta to pass from railway station to subway station
    let ttsDeltas = [
        "Кунцево": 10,
        "Фили": 7,
        "Беговая": 5,
        "Белорусская": 5
    ]
    
    let ttsNames = [
        "Кунцево": "Кунцевская",
        "Фили": "Фили",
        "Беговая": "Беговая",
        "Белорусская": "Белорусская"
    ]
    
    let subways = [
        "aeroport": "Аэропорт",
        "myasnitskaya": "Лубянка",
        "strogino": "Строгино",
        "st_basmannaya": "Курская",
        "tekstilshiki": "Текстильщики",
        "vavilova": "Ленинский проспект",
        "izmailovo": "Семёновская",
        "shabolovskaya": "Шаболовская",
        "petrovka": "Кузнецкий мост",
        "paveletskaya": "Павелецкая",
        "ilyinka": "Китай-город",
        "trehsvyat_b": "Китай-город",
        "trehsvyat_m": "Китай-город",
        "hitra": "Китай-город",
        "gnezdo": "Тверская"
    ]

}
