//
//  RouteDataModel.swift
//  Dubki
//
//  Created by Alexander Morenko on 30.10.15.
//  Copyright © 2015 Alexander Morenko. All rights reserved.
//

import UIKit

// Структура для хранения одного шага маршрута
class RouteStep {
    var from: String?        // откуда (станция метро, ж/д, автобуса)
    var to: String?          // куда (станция метро, ж/д, автобуса)
    var trainName: String?   // название поезда или ветки метро
    var stations: String?    // остановки ж/д или станции пересадки метро
    var departure: NSDate?   // время отправления
    var arrival: NSDate?     // время прибытия
    var time: Int?           // время в пути (в минутах)
    var title: String?       // заголовок шага - вид шага и время в пути (для вывода на экран)
    var detail: String?      // описание шага - станции откуда/куда и время отправления/прибытия (для вывода на экран)
    var map: String?         // имя файла карты для показа делелей шага маршрута
    var url: String?         // ссылка на расписание

    init() {
        
    }
    
    init(title:String, detail: String) {
        self.title = title
        self.detail = detail
    }

    init(title:String, detail: String, url: String) {
        self.title = title
        self.detail = detail
        self.url = url
    }
}

// Singleton Class
class RouteDataModel: NSObject {
    
    static let sharedInstance = RouteDataModel()

    // Описание общежитий
    let dormitories = NSArray(contentsOfFile: NSBundle.mainBundle().pathForResource("Dormitories", ofType: "plist")!)
    // Описание кампусов
    let campuses = NSArray(contentsOfFile: NSBundle.mainBundle().pathForResource("Campuses", ofType: "plist")!)
    // Названия станций метро
    let subways = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Subways", ofType: "plist")!)
    // Описания станций ж/д
    let stations = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Stations", ofType: "plist")!)
    
    // вид шага маршрута
    let busTitle = NSLocalizedString("Bus", comment: "") // "🚌 Автобус"
    let trainTitle = NSLocalizedString("Rail", comment: "") // "🚊 Электричка"
    let subwayTitle = NSLocalizedString("Subway", comment: "") // "🚇 Метро"
    let onfootTitle = NSLocalizedString("OnFoot", comment: "") // "🚶 Пешком"
    let minuteTitle = "минут"

    // for route
    var direction: Int? // Направление из/в Дубки
    var campus: Dictionary<String, AnyObject>? // в/из Кампус
    var when: NSDate? // когда - время
    // Маршрут
    var route: [RouteStep] = [RouteStep(title: "Не заданы параметры маршрута", detail: "")]
    
    override init() {
        super.init()
        
        // load array of campuses from resource
        //let campusesPath = NSBundle.mainBundle().pathForResource("Campuses", ofType: "plist")
        //campuses = NSArray(contentsOfFile: campusesPath!)
        //print(campuses?.count)
        
    }
    
    func calculateRoute(direction: Int, campus: Dictionary<String, AnyObject>?, when: NSDate?) {
        
        self.direction = direction
        self.campus = campus
        self.when = when
        if when == nil {
            self.when = NSDate().dateByAddingTimeInterval(600) // сейчас + 10 минут
        }
        
        if campus == nil {
            route = [RouteStep(title: "Не заданы параметры маршрута", detail: "")]
            return
        }
        
        if direction == 0 {
            // из Дубков
            route = [RouteStep]() // очистка маршрута
            
            // общая информация о пути
            let way = RouteStep()
            way.from = "Дубки"
            way.to = campus!["title"] as? String
            way.departure = self.when
            route.append(way)
           
            // автобусом
            var timestamp = way.departure
            let bus = getNearestBus("Дубки", to: "Одинцово", timestamp: &timestamp!)
            route.append(bus)
            
            // электричкой
            let stationFrom = stations!["odincovo"] as! Dictionary<String, AnyObject>
            let stationTo = stations![(campus!["station"] as? String)!] as! Dictionary<String, AnyObject>
            timestamp = bus.arrival
            let train = getNearestTrain(stationFrom, to: stationTo, timestamp: timestamp!)
            route.append(train)
            
            // на метро
            let subwayFrom = stationTo["subway"] as? String
            let subwayTo = campus!["subway"] as? String
            let timeFromStationToSubway = stationTo["onfoot"] as! Int
            timestamp = dateByAddingMinute(train.arrival!, minute: timeFromStationToSubway)
            let subway = getNearestSubway(subwayFrom!, to: subwayTo!, timestamp: timestamp!)
            route.append(subway)
            
            // пешком
            timestamp = subway.arrival
            let onfoot = getNearestOnFoot(campus!, timestamp: timestamp!)
            route.append(onfoot)
            
            // форматирование вывода на экран way
            way.arrival = onfoot.arrival
            way.time = Int(way.arrival!.timeIntervalSinceDate(way.departure!) / 60.0)
            let timeDeparture = getTimeFromDate(way.departure!)
            let timeArrival = getTimeFromDate(way.arrival!)
            way.title = "\(way.from!) → \(way.to!) (\(way.time!) \(minuteTitle))"
            //way.detail = "отправление: \(timeDeparture)  | прибытие: \(timeArrival)"
            way.detail = String(format: "отправление: %@ | прибытие: %@", timeDeparture, timeArrival)
            
//            route = [
//                RouteStep(title: "Дубки → Строгино", detail: "отправление: 09:00 | прибытие: 10:18"),
//                RouteStep(title: bus, detail: "Дубки (09:10) → Одинцово (09:25)"),
//                RouteStep(title: train, detail: "Кубинка 1 - Москва (Белорусский вокзал) (09:31 → 09:47)\nОстановки: везде\nВыходите на станции: Кунцево", url: "http://rasp.yandex.ru/"),
//                RouteStep(title: subway, detail: "Кунцевская (09:57) → Строгино (10:12)"),
//                RouteStep(title: onfoot, detail: "Примерно 6 минут", url: "strogino.jpg")
//            ]
        } else {
            // в Дубки
            route = [
                RouteStep(title: "Строгино → Дубки", detail: "отправление: 15:31 | прибытие: 17:35"),
                RouteStep(title: onfootTitle, detail: "Примерно 6 минут", url: "strogino.jpg"),
                RouteStep(title: subwayTitle, detail: "Строгино (15:37) → Кунцевская (15:52)"),
                RouteStep(title: trainTitle, detail: "Москва (Белорусский вокзал) - Можайск (16:27 → 16:39)\nОстановки: Рабочий Посёлок, Сетунь, Одинцово\nВыходите на станции: Одинцово", url: "http://rasp.yandex.ru/"),
                RouteStep(title: busTitle, detail: "Одинцово (17:20) → Дубки (17:35)")
            ]
        }
        
    }

    // MARK: - Route On Bus

    let BUS_API_URL = "http://dubkiapi2.appspot.com/sch"
    
    // from and to should be in {'Одинцово', 'Дубки'}
    func getNearestBus(from: String, to: String, inout timestamp: NSDate) -> RouteStep {
        //assert from in {'Одинцово', 'Дубки'}
        //assert to in {'Одинцово', 'Дубки'}
        //assert from != to
        
        var _from: String
        var _to: String
        
        let weekday = getDayOfWeek(timestamp)
        // today is either {'','*Суббота', '*Воскресенье'}
        if weekday == 7 {
            if from == "dubki" {
                _from = "ДубкиСуббота"
            } else if to == "dubki" {
                _to = "ДубкиСуббота"
            }
        } else if weekday == 0 {
            if from == "dubki" {
                _from = "ДубкиВоскресенье"
            } else if to == "dubki" {
                _to = "ДубкиВоскресенье"
            }
        }

        let bus: RouteStep = RouteStep()
  
        bus.from = from
        bus.to = to
        bus.departure = timestamp
        bus.arrival = dateByAddingMinute(timestamp, minute: 15)
        
        // для отображения на экране
        bus.title = busTitle
        let timeDeparture = getTimeFromDate(bus.departure!)
        let timeArrival = getTimeFromDate(bus.arrival!)
        bus.detail = "\(bus.from!) (\(timeDeparture)) → \(bus.to!) (\(timeArrival))"

        return bus
    }

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
    
    let STATIONS = [
        "Одинцово" :   "c10743",
        "Кунцево":     "s9601728",
        "Фили":        "s9600821",
        "Беговая":     "s9601666",
        "Белорусская": "s2000006"
    ]
*/
    let API_KEY_FILE = ".train_api_key"
    
    let TRAIN_API_URL = "https://api.rasp.yandex.net/v1.0/search/?apikey=%s&format=json&date=%s&from=%s&to=%s&lang=ru&transport_types=suburban"

    func getNearestTrain(from: Dictionary<String, AnyObject>, to: Dictionary<String, AnyObject>, timestamp: NSDate) -> RouteStep {
        let train: RouteStep = RouteStep()
        
        train.from = from["title"] as? String
        train.to = to["title"] as? String
        train.trainName = "Кубинка 1 - Москва (Белорусский вокзал)"
        train.url = "http://rasp.yandex.ru/"
        
        train.stations = "везде"
        train.departure = timestamp
        train.arrival = dateByAddingMinute(timestamp, minute: 15)
        
        // для отображения на экране
        train.title = trainTitle
        let timeDeparture = getTimeFromDate(train.departure!)
        let timeArrival = getTimeFromDate(train.arrival!)
//        train.detail = "\(train.trainName!) (\(timeDeparture) → \(timeArrival))\nОстановки: \(train.stations!)\nВыходите на станции: \(train.to!)"
        train.detail = String(format: "%@ (%@ → %@)\nОстановки: %@\nВыходите на станции: %@", train.trainName!, timeDeparture, timeArrival, train.stations!, train.to!)
        

        return train
    }

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
        "kuntsevskaya": [ // Кунцевская
            "strogino":            15, // Строгино
            "semenovskaya":        28, // Семёновская
            "kurskaya":            21, // Курская
            "leninskiy_prospekt" : 28  // Ленинский проспект
        ],
        "belorusskaya": [ // Белорусская
            "aeroport":  6, // Аэропорт
            "tverskaya": 4  // Тверская
        ],
        "begovaya": [ // Беговая
            "tekstilshiki":   22, // Текстильщики
            "lubyanka":       12, // Лубянка
            "shabolovskaya":  20, // Шаболовская
            "kuzneckiy_most":  9, // Кузнецкий мост
            "paveletskaya":   17, // Павелецкая
            "china-town":     11  // Китай-город
        ],
        "slavyanskiy_bulvar": [ // Славянский бульвар
            "strogino":           18, // Строгино
            "semenovskaya":       25, // Семёновская
            "kurskaya":           18, // Курская
            "leninskiy_prospekt": 25, // Ленинский проспект
            "aeroport":           26, // Аэропорт
            "tekstilshiki":       35, // Текстильщики
            "lubyanka":           21, // Лубянка
            "shabolovskaya":      22, // Шаболовская
            "kuzneckiy_most":     22, // Кузнецкий мост
            "tverskaya":          22  // Тверская
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
    
    func getNearestSubway(from: String, to: String, timestamp: NSDate) -> RouteStep {
        let subway: RouteStep = RouteStep()

        subway.from = subways![from] as? String
        subway.to = subways![to] as? String

        let subwayCloses = dateChangeTime(timestamp, time: subwayClosesTime)
        let subwayOpens = dateChangeTime(timestamp, time: subwayOpensTime)
        // subwayCloses <= timestamp <= subwayOpens
        if subwayCloses.compare(timestamp) != .OrderedDescending
            && timestamp.compare(subwayOpens) != .OrderedDescending {
            // subway is still closed
            subway.departure = subwayOpens
        } else {
            subway.departure = timestamp
        }
        subway.time = getSubwayData(from, to: to)
        subway.arrival = dateByAddingMinute(timestamp, minute: subway.time!)
        
        // для отображения на экране
        subway.title = subwayTitle
        let timeDeparture = getTimeFromDate(subway.departure!)
        let timeArrival = getTimeFromDate(subway.arrival!)
        subway.detail = "\(subway.from!) (\(timeDeparture)) → \(subway.to!) (\(timeArrival))"

        return subway
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
    
    func getNearestOnFoot(edu: Dictionary<String, AnyObject>, timestamp: NSDate) -> RouteStep {
        let onfoot: RouteStep = RouteStep()
        
        onfoot.time = edu["onfoot"] as? Int
        onfoot.departure = timestamp
        onfoot.arrival = dateByAddingMinute(timestamp, minute: onfoot.time!)
        //onfoot.map = formMapUrl(edu["mapsrc"] as! String)
        onfoot.map = (edu["name"] as? String)! + ".jpg"
        
        // для отображения на экране
        onfoot.title = onfootTitle
        onfoot.detail = String(format: "Примерно %d минут", onfoot.time!)
        //onfoot.detail = "Примерно \(onfoot.time!) минут"

        return onfoot
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
    
    func getTimeFromDate(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.stringFromDate(date)
    }
    
    func dateChangeTime(date: NSDate, time: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd "
        
        let dateString = dateFormatter.stringFromDate(date) + time
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        return dateFormatter.dateFromString(dateString)!
    }

    func dateByAddingMinute(date: NSDate, minute: Int) -> NSDate {
        return date.dateByAddingTimeInterval(Double(minute * 60))
        //let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        //let myCalendar = NSCalendar.currentCalendar()
        //return myCalendar.dateByAddingUnit([.Minute], value: minute, toDate: date, options: [])!
    }
    
    func getDayOfWeek(todayDate: NSDate) -> Int {
        //let weekdayName = ["воскресенье", "понедельник", "вторник", "среда", "четверг", "пятница", "суббота"]
        
        //let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let myCalendar = NSCalendar.currentCalendar()
        let myComponents = myCalendar.components(NSCalendarUnit.Weekday, fromDate: todayDate)
        let weekDay = myComponents.weekday - 1
        return weekDay
        //return weekdayName[weekDay]
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
