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
    let subways = NSArray(contentsOfFile: NSBundle.mainBundle().pathForResource("Subways", ofType: "plist")!)
    let stations = NSArray(contentsOfFile: NSBundle.mainBundle().pathForResource("Stations", ofType: "plist")!)
    
    // for route
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
    
    // TODO: change Int on Dictionary<String, AnyObject>
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

    // MARK: - Route On Bus

    // MARK: - Route On Train

/*
    // maps edus to preferred stations
    // TODO: move to Campuses.plist
    let prefStations = [
        "aeroport":      "Белорусская",
        "strogino":      "Кунцево",
        "myasnitskaya":  "Беговая",
        "vavilova":      "Кунцево",
        "izmailovo":     "Кунцево",
        "tekstilshiki":  "Беговая",
        "st_basmannaya": "Кунцево",
        "shabolovskaya": "Беговая",
        "petrovka":      "Беговая",
        "paveletskaya":  "Беговая",
        "ilyinka":       "Беговая",
        "trehsvyat_b":   "Беговая",
        "trehsvyat_m":   "Беговая",
        "hitra":         "Беговая",
        "gnezdo":        "Белорусская"
    ]

    // delta to pass from railway station to subway station
    // TODO: move to Stations.plist
    let ttsDeltas = [
        "Кунцево":    10,
        "Фили":        7,
        "Беговая":     5,
        "Белорусская": 5
    ]

    // relation between railway station and subway station
    // TODO: move to Stations.plist
    let ttsNames = [
        "Кунцево":     "Кунцевская",
        "Фили":        "Фили",
        "Беговая":     "Беговая",
        "Белорусская": "Белорусская"
    ]
*/

    // MARK: - Route On Subway

/*
    // TODO: move to Campuses.plist
    let subways = [
        "aeroport":      "Аэропорт",
        "myasnitskaya":  "Лубянка",
        "strogino":      "Строгино",
        "st_basmannaya": "Курская",
        "tekstilshiki":  "Текстильщики",
        "vavilova":      "Ленинский проспект",
        "izmailovo":     "Семёновская",
        "shabolovskaya": "Шаболовская",
        "petrovka":      "Кузнецкий мост",
        "paveletskaya":  "Павелецкая",
        "ilyinka":       "Китай-город",
        "trehsvyat_b":   "Китай-город",
        "trehsvyat_m":   "Китай-город",
        "hitra":         "Китай-город",
        "gnezdo":        "Тверская"
    ]
*/

    // Subway Route Data (timedelta in minutes)
    let subwayData = [
        "kuntsevskaya": [
            "strogino":            15,
            "semenovskaya":        28,
            "kurskaya":            21,
            "leninskiy_prospekt" : 28
        ],
        "belorusskaya": [
            "aeroport":  6,
            "tverskaya": 4
        ],
        "begovaya": [
            "tekstilshiki":   22,
            "lubyanka":       12,
            "shabolovskaya":  20,
            "kuzneckiy_most":  9,
            "paveletskaya":   17,
            "china-town":     11
        ],
        "slavyanskiy_bulvar": [
            "strogino":       18,
            "semenovskaya":   25,
            "kurskaya":       18,
            "leninskiy_prospekt": 25,
            "aeroport":       26,
            "tekstilshiki":   35,
            "lubyanka":       21,
            "shabolovskaya":  22,
            "kuzneckiy_most": 22,
            "tverskaya":      22
        ]
    ]
    let subwayClosesTime = "01:00"
    let subwayOpensTime = "05:50"

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
    
    func getNearestSubway(from: String, to: String, inout timestamp: NSDate) -> Dictionary<String, AnyObject> {
        var result: Dictionary<String, AnyObject> = ["from": from, "to": to]

        let subwayCloses = dateChangeTime(timestamp, time: subwayClosesTime)
        let subwayOpens = dateChangeTime(timestamp, time: subwayOpensTime)
        // subwayCloses <= timestamp <= subwayOpens
        if subwayCloses.compare(timestamp) != NSComparisonResult.OrderedDescending
            && timestamp.compare(subwayOpens) != NSComparisonResult.OrderedDescending {
            // subway is still closed
            timestamp = subwayOpens
        }
        result["departure"] = timestamp
        result["arrival"] = dateByAddingMinute(timestamp, minute: getSubwayData(from, to: to))
        
        return result
    }

    // MARK: - Route On Foot
/*
    // On Foot Data (timedelta in minutes) 
    // TODO: move to Campuses.plist
    let onFootEduDeltas = [
        "aeroport":      14,
        "strogino":       6,
        "myasnitskaya":   6,
        "vavilova":       5,
        "izmailovo":     16,
        "tekstilshiki":  10,
        "st_basmannaya": 16,
        "shabolovskaya":  4,
        "petrovka":       6,
        "paveletskaya":   5,
        "ilyinka":        7,
        "trehsvyat_b":   13,
        "trehsvyat_m":   15,
        "hitra":         13,
        "gnezdo":         5
    ]
    
    // TODO: move to Campuses.plist
    let mapSources = [
        "aeroport":      "9kfYmO7lbg2o_YuSTvZqiY9rCevo23cs",
        "strogino":      "pMeBRyKZjz3PnQn4HCZKIlagbMIv2Bxp",
        "myasnitskaya":  "GGWd7qLfRklaR5KSQQpKFOiJT8RPFGO-",
        "vavilova":      "_Cz-NprpRRfD15AECXvyxGQb5N7RY3xC",
        "izmailovo":     "tTSwzei04UwodpOe5ThQSKwo47ZiR8aO",
        "tekstilshiki":  "IcVLk9vNC1afHy5ge05Ae07wahHXZZ7H",
        "st_basmannaya": "LwunOFh66TXk8NyRAgKpsssV0Gdy34pG",
        "shabolovskaya": "0enMIqcJ_dLy8ShEHN34Lu-4XBAHsrno",
        "petrovka":      "pSiE6gI2ftRfAGBDauSW0G0H2o9R726u",
        "paveletskaya":  "1SimW8pYfuzER0tbTEYFs1RFaNUFnhh-",
        "ilyinka":       "7UEkPE7kT0Bhb4rOzDbk2O57LdWBE8Lq",
        "trehsvyat_b":   "_WWkurGGUbabsiPE9xgdLP_iJ61vbJrZ",
        "trehsvyat_m":   "jBGwqmV8V-JjFzbG2M_13sGlAUVqug-9",
        "hitra":         "j1cHqL5k2jw_MK31dlBLEwPPPmj72NNg",
        "gnezdo":        "_a_UjKz_rMbmf2l_mWtsRUjlaqlRySIS"
    ]
*/
    func formMapUrl(mapSource: String, type: String = "img") -> String? {
        if type == "img" {
            return "https://api-maps.yandex.ru/services/constructor/1.0/static/?sid=" + mapSource
        } else if type == "script" {
            return "https://api-maps.yandex.ru/services/constructor/1.0/js/?sid=" + mapSource
        }
        return nil
    }
    
    func getNearestOnFoot(edu: Dictionary<String, AnyObject>, timestamp: NSDate) -> Dictionary<String, AnyObject> {
        let onFootEduDeltas: Int = edu["onfoot"] as! Int

        var result: Dictionary<String, AnyObject> = ["departure": timestamp]
        result["arrival"] = dateByAddingMinute(timestamp, minute: onFootEduDeltas)
        result["time"] = onFootEduDeltas
        result["mapsrc"] = formMapUrl(edu["mapsrc"] as! String)
        
        return result
    }

    /*******************************/
/*
    // dormitory
    let dorms = [
        "dubki": "Дубки",
    ]
    
    // campus
    let edus = [
        "aeroport":      "Кочновский проезд (метро Аэропорт)",
        "strogino":      "Строгино",
        "myasnitskaya":  "Мясницкая (метро Лубянка)",
        "vavilova":      "Вавилова (метро Ленинский проспект)",
        "izmailovo":     "Кирпичная улица (метро Семёновская)",
        "tekstilshiki":  "Текстильщики",
        "st_basmannaya": "Старая Басманная",
        "shabolovskaya": "Шаболовская",
        "petrovka":      "Петровка (метро Кузнецкий мост)",
        "paveletskaya":  "Малая Пионерская (метро Павелецкая)",
        "ilyinka":       "Ильинка (метро Китай-город)",
        "trehsvyat_b":   "Большой Трёхсвятительский переулок (метро Китай-город)",
        "trehsvyat_m":   "Малый Трёхсвятительский переулок (метро Китай-город)",
        "hitra":         "Хитровский переулок (метро Китай-город)",
        "gnezdo":        "Малый Гнездниковский переулок (метро Тверская)"
    ]
*/
     
    // MARK: - Function for working with date
    
    func dateChangeTime(date: NSDate, time: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd "
        
        let dateString = dateFormatter.stringFromDate(date) + time
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        return dateFormatter.dateFromString(dateString)!
    }

    func dateByAddingMinute(date: NSDate, minute: Int) -> NSDate {
        //return date.dateByAddingTimeInterval(Double(minute * 60))
        //let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let myCalendar = NSCalendar.currentCalendar()
        return myCalendar.dateByAddingUnit([.Minute], value: minute, toDate: date, options: [])!
    }
    
    // get interval from two date (of date on further date and pass the earlier date as parameter, this would give the time difference in seconds)
    //let interval = date1.timeIntervalSinceDate(date2)
    
    // get component from date
//    let date = NSDate()
//    let calendar = NSCalendar.currentCalendar()
//    let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: date)
//    let hour = components.hour
//    let minutes = components.minute
}
