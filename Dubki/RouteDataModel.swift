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
    // вид шага маршрута
    enum RouteStepType {
        case None
        case Total
        case Bus
        case Train
        case Subway
        case Onfoot
        case Transition
    }
    
    var type: RouteStepType  // вид шага
    var from: String?        // откуда (станция метро, ж/д, автобуса)
    var to: String?          // куда (станция метро, ж/д, автобуса)
    var trainName: String?   // название поезда или ветки метро
    var stations: String?    // остановки ж/д или станции пересадки метро
    var departure: NSDate?   // время отправления
    var arrival: NSDate?     // время прибытия
    var duration: Int?       // время в пути (в минутах)
    var map: String?         // имя файла карты для показа делелей шага маршрута
    var url: String?         // ссылка на расписание
    
    // заголовок шага - вид шага и время в пути (для вывода на экран)
    var title: String? {
        get {
            switch (type) {
            case .None:
                return NSLocalizedString("NoneParameter", comment: "")
 
            case .Total:
                let titleFormat = NSLocalizedString("TotalTitleFormat", comment: "")
                return String (format: titleFormat, from ?? "?", to ?? "?", duration ?? 0)
            
            case .Bus:
                return NSLocalizedString("Bus", comment: "") // "🚌 Автобус"
            
            case .Train:
                return NSLocalizedString("Train", comment: "") // "🚊 Электричка"
            
            case .Subway:
                return NSLocalizedString("Subway", comment: "") // "🚇 Метро"
            
            case .Onfoot:
                return NSLocalizedString("OnFoot", comment: "") // "🚶 Пешком"

            case .Transition:
                return NSLocalizedString("Transition", comment: "") // "🚶 Переход"
            }
        }
    }
    
    // описание шага - станции откуда/куда и время отправления/прибытия (для вывода на экран)
    var detail: String? {
        get {
            let timeDeparture = getTimeFromDate(departure)
            let timeArrival = getTimeFromDate(arrival)

            switch (type) {
            case .None:
                return ""
            
            case .Total:
                let dateDeparture = stringFromDate(departure)
                //let dateArrival = stringFromDate(arrival)
                let detailFormat = NSLocalizedString("TotalDetailFormat", comment: "")
                return String(format: detailFormat, dateDeparture, timeArrival)
            
            case .Bus:
                return String(format: "%@ (%@) → %@ (%@)", from ?? "?", timeDeparture, to ?? "?", timeArrival)
            
            case .Train:
                let detailFormat = NSLocalizedString("TrainDetailFormat", comment: "")
                return String(format: detailFormat, trainName ?? "?", timeDeparture, timeArrival, stations ?? "везде", to ?? "?")
            
            case .Subway:
                return String(format: "%@ (%@) → %@ (%@)", from ?? "?", timeDeparture, to ?? "?", timeArrival)
            
            case .Onfoot:
                let detailFormat = NSLocalizedString("OnfootDetailFormat", comment: "")
                return String(format: detailFormat, duration ?? 0)

            case .Transition:
                let detailFormat = NSLocalizedString("TransitDetailFormat", comment: "")
                return String(format: detailFormat, from ?? "?", to ?? "?", duration ?? 0)
            }
        }
    }

    init() {
        type = .None
    }
    
    init(type: RouteStepType) {
        self.type = type
    }

    func stringFromDate(date: NSDate?) -> String {
        if date == nil {
            return "?"
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMM HH:mm"
        return dateFormatter.stringFromDate(date!)
    }

    func getTimeFromDate(date: NSDate?) -> String {
        if date == nil {
            return "?"
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.stringFromDate(date!)
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
    
    // параметры для маршрута
    var direction: Int? // Направление из/в Дубки
    var campus: Dictionary<String, AnyObject>? // в/из Кампус
    var when: NSDate? // когда - время
    // Маршрут
    var route: [RouteStep] = [RouteStep(type: .None)]
    
    override init() {
        super.init()
        
        // load array of campuses from resource
        //let dormitoriesPath = NSBundle.mainBundle().pathForResource("Dormitories", ofType: "plist")
        //let dormitories = NSArray(contentsOfFile: dormitoriesPath!)
        //print(dormitories?.count)
        
    }
    
    /**
    Calculates a route as if timestamp is the time of arrival
    
    Args:
        direction (Int): flow from/to dormitory
        campus (Dictionary): place edu of arrival/departure
        timestampEnd(NSDate): expected time of arrival
    
    Returns:
        route (Array): a calculated route
    */
    func calculateRouteReverse(direction: Int, campus: Dictionary<String, AnyObject>, timestampEnd: NSDate) {
        let departureTime = dateByAddingMinute(timestampEnd, minute: -(2*60 + 30)) // -02:30
        calculateRoute(direction, campus: campus, when: departureTime)
    }

    /**
    Calculates a route as if timestamp is the time of departure
    
    Args:
        direction (Int): flow from/to dormitory
        campus (Dictionary): place edu of arrival/departure
        timestamp(Optional[NSDate]): time of departure.
            Defaults to the current time plus 10 minutes.
        src(Optional[str]): function caller ID (used for logging)
    
    Returns:
        route (Array): a calculated route
    */
    func calculateRoute(direction: Int, campus: Dictionary<String, AnyObject>?, when: NSDate?) {
        
        self.direction = direction
        self.campus = campus
        self.when = when
        if when == nil {
            self.when = NSDate().dateByAddingTimeInterval(600) // сейчас + 10 минут на сборы
        }
        
        if campus == nil {
            route = [RouteStep(type: .None)]
            return
        }
        
        let dorm = dormitories![0] as! Dictionary<String, AnyObject>

        route = [RouteStep]() // очистка маршрута
        
        if direction == 0 {
            // из Дубков
            
            // общая информация о пути
            let way = RouteStep(type: .Total)
            way.from = dorm["title"] as? String
            way.to = campus!["title"] as? String
            route.append(way)
           
            // Маршрут: Автобус->Переход->Электричка->Переход->Метро->Пешком

            // автобусом
            let bus = getNearestBus("Дубки", to: "Одинцово", timestamp: self.when!)
            route.append(bus)
            
            // станции метро
            var subwayFrom: String?     // станция метро после транзита
            var transitArrival: NSDate? // время пребытия к метро
            
            if bus.to == "Славянский бульвар" {
                // станции метро

                subwayFrom = "slavyanskiy_bulvar"
                // переход
                let transit = RouteStep(type: .Transition)
                transit.from = "Автобус"
                transit.to = bus.to
                transit.duration = 5
                transit.departure = bus.arrival!
                transit.arrival = dateByAddingMinute(transit.departure!, minute: transit.duration!)
                if transit.duration > 0 {
                    route.append(transit)
                }
                
                // время прибытия
                transitArrival = transit.arrival!
           } else {
                // станции ж/д
                let stationFrom = stations![(dorm["station"] as? String)!] as! Dictionary<String, AnyObject>
                let stationTo = stations![(campus!["station"] as? String)!] as! Dictionary<String, AnyObject>
                
                // переход
                let transit1 = RouteStep(type: .Transition)
                transit1.from = "Автобус"
                transit1.to = "Станция"
                transit1.duration = stationFrom["transit"] as? Int
                transit1.departure = bus.arrival!
                transit1.arrival = dateByAddingMinute(transit1.departure!, minute: transit1.duration!)
                if transit1.duration > 0 {
                    route.append(transit1)
                }
                
                // электричкой
                let train = getNearestTrain(stationFrom, to: stationTo, timestamp: transit1.arrival!)
                route.append(train)
                
                // станции метро
                subwayFrom = stationTo["subway"] as? String
                
                // переход
                let transit2 = RouteStep(type: .Transition)
                transit2.from = stationTo["title"] as? String
                transit2.to = subways![subwayFrom!] as? String
                transit2.duration = stationTo["transit"] as? Int
                transit2.departure = train.arrival!
                transit2.arrival = dateByAddingMinute(transit2.departure!, minute: transit2.duration!)
                if transit2.duration > 0 {
                    route.append(transit2)
                }
                
                // время прибытия
                transitArrival = transit2.arrival
            }

            // на метро
            let subwayTo = campus!["subway"] as? String
            let subway = getNearestSubway(subwayFrom!, to: subwayTo!, timestamp: transitArrival!)
            route.append(subway)
            
            // пешком
            let onfoot = getNearestOnFoot(campus!, timestamp: subway.arrival!)
            route.append(onfoot)
            
            // форматирование информации о пути
            way.departure = bus.departure
            way.arrival = onfoot.arrival
            way.duration = Int(way.arrival!.timeIntervalSinceDate(way.departure!) / 60.0)
            
        } else {
            // в Дубки

            // общая информация о пути
            let way = RouteStep(type: .Total)
            way.from = campus!["title"] as? String
            way.to = dorm["title"] as? String
            route.append(way)
            
            // Маршрут: Пешком->Метро->Переход->Электричка->Переход->Автобус

            // пешком
            let onfoot = getNearestOnFoot(campus!, timestamp: self.when!)
            route.append(onfoot)
            
            // станции ж/д
            let stationFrom = stations![(campus!["station"] as? String)!] as! Dictionary<String, AnyObject>
            
            // на метро
            let subwayFrom = campus!["subway"] as? String
            let subwayTo = stationFrom["subway"] as? String
            let subway = getNearestSubway(subwayFrom!, to: subwayTo!, timestamp: onfoot.arrival!)
            route.append(subway)

            //TODO: добавить обработку автобуса от м.Славянский бульвар
            
            // переход
            let transit1 = RouteStep(type: .Transition)
            transit1.from = subways![subwayTo!] as? String
            transit1.to = stationFrom["title"] as? String
            transit1.duration = stationFrom["transit"] as? Int
            transit1.departure = subway.arrival
            transit1.arrival = dateByAddingMinute(transit1.departure!, minute: transit1.duration!)
            if transit1.duration > 0 {
                route.append(transit1)
            }

            //электричкой
            let stationTo = stations![(dorm["station"] as? String)!] as! Dictionary<String, AnyObject>
            let train = getNearestTrain(stationFrom, to: stationTo, timestamp: transit1.arrival!)
            route.append(train)

            // переход
            let transit2 = RouteStep(type: .Transition)
            transit2.from = "Станция"
            transit2.to = "Автобус"
            transit2.duration = stationTo["transit"] as? Int
            transit2.departure = train.arrival
            transit2.arrival = dateByAddingMinute(transit2.departure!, minute: transit2.duration!)
            if transit2.duration > 0 {
                route.append(transit2)
            }

            // автобусом
            let bus = getNearestBus("Одинцово", to: "Дубки", timestamp: transit2.arrival!)
            route.append(bus)
            
            // форматирование информации о пути
            way.departure = onfoot.departure
            way.arrival = bus.arrival
            way.duration = Int(way.arrival!.timeIntervalSinceDate(way.departure!) / 60.0)
        }
    }

    // MARK: - Route On Bus


    // загрузка расписания автобусов Дубки-Одинцово в файл bus.json
    func loadBusSchedule() -> JSON? {
        let BUS_API_URL = "https://dubkiapi2.appspot.com/sch"
        let BUS_SCHEDULE_FILE = "bus.json"
        
        // полный путь к файлу bus.json
        //let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        //let destinationUrl = documentsUrl.URLByAppendingPathComponent("filteredImage.png")
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        //let destinationPath = documentsPath.stringByAppendingPathComponent("filename.ext")
        let filePath = "\(documentsPath)/\(BUS_SCHEDULE_FILE)"

        // загрузка распияния из интернета
        if let busSchedule = NSData(contentsOfURL: NSURL(string: BUS_API_URL)!) {
            // сохранить расписание в файл bus.json
            busSchedule.writeToFile(filePath, atomically: true)
            
            return JSON(data: busSchedule)
        }

        // загрузка расписания из файла bus.json
        if let busSchedule = NSData(contentsOfFile: filePath) {
            return JSON(data: busSchedule)
        }
        return nil
    }
    
    /**
    Caches the bus schedule to `SCHEDULE_FILE`
    Получить расписание автобусов на день
    */
    func getBusSchedule(from: String, to: String, timestamp: NSDate, useAsterisk: Bool = true) -> [String] {
        var _from: String = from
        var _to: String = to
        
        let weekday = getDayOfWeek(timestamp)
        // today is either {'', '*Суббота', '*Воскресенье'}
        if weekday == 7 {
            if from == "Дубки" {
                _from = "ДубкиСуббота"
            } else if to == "Дубки" {
                _to = "ДубкиСуббота"
            }
        } else if weekday == 0 {
            if from == "Дубки" {
                _from = "ДубкиВоскресенье"
            } else if to == "Дубки" {
                _to = "ДубкиВоскресенье"
            }
        }
        
        // загрузка расписания
        var times = [String]() // время отправления автобуса
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        if let busSchedule = loadBusSchedule() {
            // find current schedule
            for elem in busSchedule.array! {
                let elemFrom = elem["from"].string
                let elemTo = elem["to"].string
                if elemFrom == _from && elemTo == _to {
                    let currentSchedule = elem["hset"].array
                    // convert to array of time
                    for time in currentSchedule! {
                        times.append(time["time"].string!)
                    }
                    break
                }
            }
            
            if times.count == 0 {
                //TODO: добавить сообщение об ошибки пользователю
                print("Ошибка: В расписании автобуса нет направления \(_from)->\(_to)")
            }
        } else {
            //TODO: добавить сообщение об ошибки пользователю
            print("Не получилось загрузить расписание автобуса")
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        return times
    }
    
    /**
    Returns the nearest bus
    
    Args:
        from(String): place of departure
        to(String): place of arrival
        timestamp(NSDate): time of departure
    
    Note:
        'from' and 'to' should not be equal and should be in {'Одинцово', 'Дубки'}
    */
    func getNearestBus(from: String, to: String, timestamp: NSDate, useAsterisk: Bool = true) -> RouteStep {
        // from and to should be in {'Одинцово', 'Дубки'}
        let vals = ["Одинцово", "Дубки"]
        //assert from in {'Одинцово', 'Дубки'}
        assert(vals.contains(from))
        //assert to in {'Одинцово', 'Дубки'}
        assert(vals.contains(to))
        //assert(from != to)
        assert(from != to, "From equal To")
        
        var _from: String = from
        var _to: String = to
        
        let weekday = getDayOfWeek(timestamp)
        // today is either {'', '*Суббота', '*Воскресенье'}
        if weekday == 7 {
            if from == "Дубки" {
                _from = "ДубкиСуббота"
            } else if to == "Дубки" {
                _to = "ДубкиСуббота"
            }
        } else if weekday == 0 {
            if from == "Дубки" {
                _from = "ДубкиВоскресенье"
            } else if to == "Дубки" {
                _to = "ДубкиВоскресенье"
            }
        }

        // загрузка расписания
        var times = [String]() // время отправления автобуса
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        if let busSchedule = loadBusSchedule() {
            // find current schedule
            for elem in busSchedule.array! {
                let elemFrom = elem["from"].string
                let elemTo = elem["to"].string
                if elemFrom == _from && elemTo == _to {
                    let currentSchedule = elem["hset"].array
                    // convert to array of time
                    for time in currentSchedule! {
                        times.append(time["time"].string!)
                    }
                    break
                }
            }
            
            if times.count == 0 {
                //TODO: добавить сообщение об ошибки пользователю
                print("Ошибка: В расписании автобуса нет направления \(_from)->\(_to)")
                return RouteStep()
            }
        } else {
            //TODO: добавить сообщение об ошибки пользователю
            print("Не получилось загрузить расписание автобуса")
            return RouteStep()
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
 
        // поиск ближайшего рейса (минимум ожидания)
        var minInterval: Double = 24*60*60 // мин. интервал (сутки)
        var busDeparture: NSDate?          // время отправления
        var slBlvdBus: Bool = false        // автобус до м.Славянский бульвара

        for time in times {
            var timeWithoutAsteriks = time
            // asterisk indicates bus arrival/departure station is 'Славянский бульвар'
            // it needs special handling
            if time.containsString("*") {
                if !useAsterisk { continue } // не использовать автобус до м. Славянский бульвар
                timeWithoutAsteriks = time.substringToIndex(time.endIndex.predecessor())
            }
            let departure = dateChangeTime(timestamp, time: timeWithoutAsteriks)
            let interval: Double = departure.timeIntervalSinceDate(timestamp)
            //TODO: # FIXME works incorrectly between weekday 6-7-1
            if interval > 0 && interval < minInterval {
                minInterval = interval
                busDeparture = departure
                slBlvdBus = time.containsString("*")
            }
        }
        if busDeparture == nil {
            //print("Ближайший автобус не найден")
            // get nearest bus on next day
            let newTimestamp = dateChangeTime(dateByAddingDay(timestamp, day: 1), time: "00:00")
            return getNearestBus(from, to: to, timestamp: newTimestamp)
        }

        let bus: RouteStep = RouteStep(type: .Bus)
  
        bus.from = from
        if useAsterisk && slBlvdBus {
            bus.to = "Славянский бульвар"
            bus.duration = 50 // время автобуса в пути
        } else {
            bus.to = to
            bus.duration = 15 // время автобуса в пути
        }
        bus.departure = busDeparture
        //TODO: # FIXME: more real arrival time?
        bus.arrival = dateByAddingMinute(bus.departure!, minute: bus.duration!)
        
        return bus
    }

    // MARK: - Route On Train

    /*
    A module which calculates the nearest train using an external API (Yandex.Rasp)
    Note that developer key for Yandex.Rasp is required (stored in .train_api_key)
    Also caches a schedule for today and two days later for faster access
    Key location and cached schedules' files are likely to change in future
    */

    let YANDEX_API_KEY = "6666221e-446b-44d3-8bcb-274e5103aacc"
    
    // URL of train schedule API provider
    let TRAIN_API_URL = "https://api.rasp.yandex.net/v1.0/search/?apikey=%@&format=json&date=%@&from=%@&to=%@&lang=ru&transport_types=suburban"

    /*
    Caches a schedule between all stations
    */
    func cacheEverything() {
        let from = "Одинцово"
        let toStations = ["Кунцево", "Фили", "Беговая", "Белорусская"]
        for to in toStations {
            cacheScheduleTrain(from, to: to, timestamp: NSDate())
            cacheScheduleTrain(to, to: from, timestamp: NSDate())
        }
    }

    /*
    Caches a schedule between stations from arguments starting with certain day
    Writes the cached schedule for day and two days later to train_cached_* files
    
    Args:
        from(String): departure train station
        to(String): arrival train station
        timestamp(NSDate): date to cache schedule for
    */
    func cacheScheduleTrain(from: String, to: String, timestamp: NSDate) {
        
    }

    /*
    Returns a cached schedule between stations in arguments
    If no cached schedule is available, download and return a fresh one
    
    Args:
        from(String): departure train station
        to(String): arrival train station
        timestamp(NSDate): date to get schedule for
    */
    func getScheduleTrain(from: String, to: String, timestamp: NSDate) -> JSON? {
        let departure = stringFromDate(dateChangeTime(timestamp, time: "09:00"), dateFormat: "yyyy-MM-dd HH:mm:ss")
        let arrival = stringFromDate(dateChangeTime(timestamp, time: "09:35"), dateFormat: "yyyy-MM-dd HH:mm:ss")
        let data = "[{\"departure\":\"\(departure)\",\"arrival\":\"\(arrival)\",\"stops\":\"везде\",\"thread\":{\"title\":\"Кубинка 1 - Москва (Белорусский вокзал)\"}}]"

        return JSON(data: data.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    /*
    Returns the nearest train
    
    Args:
        from(Dictionary): place of departure
        to(Dictionary): place of arrival
        timestamp(NSDate): time of departure
    
    Note:
        'from' and 'to' should not be equal and should be in STATIONS
    */
    func getNearestTrain(from: Dictionary<String, AnyObject>, to: Dictionary<String, AnyObject>, timestamp: NSDate) -> RouteStep {
        //assert _from in STATIONS
        //assert _to in STATIONS
        
        let fromCode = from["code"] as? String
        let toCode = to["code"] as? String
        let schedule = getScheduleTrain(fromCode!, to: toCode!, timestamp: timestamp)
        
        var trains = [Dictionary<String, String>]()
        for item in (schedule?.array)! {
            var train = Dictionary<String, String>()
            train["arrival"] = item["arrival"].string
            train["departure"] = item["departure"].string
            train["stops"] = item["stops"].string
            train["title"] = item["thread"]["title"].string
            trains.append(train)
        }
        
        // поиск ближайшего рейса (минимум ожидания)
        var minInterval: Double = 24*60*60 // мин. интервал (сутки)
        var trainInfo: Dictionary<String, String>? // поезд
        for train in trains {
            let departure = dateFromString(train["departure"]!, dateFormat: "yyyy-MM-dd HH:mm:ss")
            let interval: Double = departure.timeIntervalSinceDate(timestamp)
            if interval > 0 && interval < minInterval {
                minInterval = interval
                trainInfo = train
            }
        }

        if trainInfo == nil {
            //print("Ближайшая электричка не найдена")
            // get nearest train on next day
            let newTimestamp = dateChangeTime(dateByAddingDay(timestamp, day: 1), time: "00:00")
            return getNearestTrain(from, to: to, timestamp: newTimestamp)
        }
        
        let train: RouteStep = RouteStep(type: .Train)
        
        train.from = from["title"] as? String
        train.to = to["title"] as? String
        train.trainName = trainInfo!["title"] //"Кубинка 1 - Москва (Белорусский вокзал)"
        train.stations = trainInfo!["stops"] //"везде"
        train.departure = dateFromString(trainInfo!["departure"]!, dateFormat: "yyyy-MM-dd HH:mm:ss")
        train.arrival = dateFromString(trainInfo!["arrival"]!, dateFormat: "yyyy-MM-dd HH:mm:ss")
        train.duration = Int(train.arrival!.timeIntervalSinceDate(train.departure!) / 60)
        train.url = "http://rasp.yandex.ru/"
        
        return train
    }

    // MARK: - Route On Subway

    // Subway Route Data (timedelta in minutes)
    let subwayDuration = [
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

    /**
    Returns the time required to get from one subway station to another
    
    Args:
        from(String): Russian name of station of departure
        to(String): Russian name of station of arrival
    
    Note:
        'from' and 'to' must exist in SUBWAY_DATA.keys or any of SUBWAY_DATA[key].values
    */
    func getSubwayDuration(from: String, to: String) -> Int {
        if let fromStation = subwayDuration[from] {
            if let result = fromStation[to] {
                return result
            }
        }
        if let toStation = subwayDuration[to] {
            if let result = toStation[from] {
                return result
            }
        }
        print("not fround subway data from: \(from) to: \(to)")
        return 0
    }
    
    /**
    Returns the nearest subway route
    
    Args:
        from(String): Russian name of station of departure
        to(String): Russian name of station of arrival
        timestamp(NSDate): time of departure
    
    Note:
        'from' and 'to' must exist in SUBWAY_DATA.keys or any of SUBWAY_DATA[key].values
    */
    func getNearestSubway(from: String, to: String, timestamp: NSDate) -> RouteStep {
        let subway: RouteStep = RouteStep(type: .Subway)

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
        subway.duration = getSubwayDuration(from, to: to)
        subway.arrival = dateByAddingMinute(subway.departure!, minute: subway.duration!)
        
        return subway
    }

    // MARK: - Route On Foot

    /**
    Returns a map url for displaying in a webpage
    
    Args:
        edu(Dictionary): which education campus the route's destination is
        urlType(Optional[String]): whether the map should be interactive
    
    Note:
        'edu' should be a value from EDUS
        'urlType' should be in {'static', 'js'}
    */
    func formMapUrl(edu: Dictionary<String, AnyObject>, urlType: String = "static") -> String? {
        let mapSource = edu["mapsrc"] as! String
        return String(format: "https://api-maps.yandex.ru/services/constructor/1.0/%@/?sid=%@", urlType, mapSource)
    }
    
    /**
    Returns the nearest onfoot route
    
    Args:
        edu(Dictionary): place of arrival
        timestamp(NSDate): time of departure from subway exit
    
    Note:
        'edu' should be a value from EDUS
    */
    func getNearestOnFoot(edu: Dictionary<String, AnyObject>, timestamp: NSDate) -> RouteStep {
        let onfoot: RouteStep = RouteStep(type: .Onfoot)
        
        onfoot.duration = edu["onfoot"] as? Int
        onfoot.departure = timestamp
        onfoot.arrival = dateByAddingMinute(timestamp, minute: onfoot.duration!)
        //onfoot.map = formMapUrl(edu["mapsrc"] as! String)
        onfoot.map = edu["name"] as? String
        
        return onfoot
    }

    // MARK: - Function for URL request
    
     // Synchronous Request
    func synchronousRequest(url: NSURL) -> NSData? {
        var result: NSData? = nil
        
        let session = NSURLSession.sharedSession()
        
        // set semaphore
        let sem = dispatch_semaphore_create(0)
        
        let task1 = session.dataTaskWithURL(url, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            //print(response)
            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            //let jsonData = JSON(data: data!)
            result = data
            
            // delete semophore
            dispatch_semaphore_signal(sem)
        })
        // run parallel thread
        task1.resume()
        
        // white delete semophore
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER)
        
        return result
    }

    // MARK: - Function for working with date
    
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
    
    func dateByAddingDay(date: NSDate, day: Int) -> NSDate {
        //let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let myCalendar = NSCalendar.currentCalendar()
        if #available(iOS 8.0, *) {
            return myCalendar.dateByAddingUnit([.Day], value: day, toDate: date, options: [])!
        } else {
            // Fallback on earlier versions
            let dateComponents = NSDateComponents()
            dateComponents.day = day
            return myCalendar.dateByAddingComponents(dateComponents, toDate: date, options: [])!
        }
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
    
    func dateFromString(date: String, dateFormat: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.dateFromString(date)!
    }
    
    func stringFromDate(date: NSDate, dateFormat: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.stringFromDate(date)
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
