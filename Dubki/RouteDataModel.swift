//
//  RouteDataModel.swift
//  Dubki
//
//  Created by Alexander Morenko on 30.10.15.
//  Copyright © 2015 LionSoft, LLC. All rights reserved.
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
    var stops: String?       // остановки ж/д или станции пересадки метро
    var departure: NSDate    // время отправления
    var arrival: NSDate      // время прибытия
    var duration: Int        // время в пути (в минутах)
    var map: String?         // имя файла карты для показа делелей шага маршрута
    var url: String?         // ссылка на расписание
    
    // заголовок шага - вид шага и время в пути (для вывода на экран)
    var title: String? {
        get {
            switch (type) {
            case .None:
                return NSLocalizedString("NoneParameter", comment: "")
 
            case .Total:
                //let titleFormat = NSLocalizedString("TotalTitleFormat", comment: "")
                return String (format: "🏁 %@ → %@", from ?? "?", to ?? "?")
            
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
            let timeDeparture = departure.string("HH:mm") ?? "?"
            let timeArrival = arrival.string("HH:mm") ?? "?"

            switch (type) {
            case .None:
                return ""
            
            case .Total:
                let dateDeparture = departure.string("dd MMM HH:mm") ?? "?"
                //let dateArrival = arrival?.stringByFormat("dd MMM HH:mm") ?? "?"
                let detailFormat = NSLocalizedString("TotalDetailFormat", comment: "")
                return String(format: detailFormat, dateDeparture, timeArrival, duration ?? 0)
            
            case .Bus:
                return String(format: "%@ (%@) → %@ (%@)", from ?? "?", timeDeparture, to ?? "?", timeArrival)
            
            case .Train:
                let detailFormat = NSLocalizedString("TrainDetailFormat", comment: "")
                return String(format: detailFormat, trainName ?? "?", timeDeparture, timeArrival, stops ?? "везде", to ?? "?")
            
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
        departure = NSDate()
        arrival = NSDate()
        duration = 0
    }
    
    init(type: RouteStepType) {
        self.type = type
        departure = NSDate()
        arrival = NSDate()
        duration = 0
    }
}

class RouteDataModel: NSObject {
    
    // Singleton Class
    static let sharedInstance = RouteDataModel()

    // Описание общежитий
    let dormitories = NSArray(contentsOfFile: NSBundle.mainBundle().pathForResource("Dormitories", ofType: "plist")!) as? [Dictionary<String, AnyObject>]
    // Описание кампусов
    let campuses = NSArray(contentsOfFile: NSBundle.mainBundle().pathForResource("Campuses", ofType: "plist")!) as? [Dictionary<String, AnyObject>]
    // Названия станций метро
    let subways = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Subways", ofType: "plist")!) as? Dictionary<String, AnyObject>
    // Описания станций ж/д
    let stations = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Stations", ofType: "plist")!) as? Dictionary<String, AnyObject>
    
    let scheduleService = ScheduleService.sharedInstance
    
    // параметры для маршрута
    //var direction: Int? // Направление из/в Дубки
    //var campus: Dictionary<String, AnyObject>? // в/из Кампус
    //var when: NSDate? // когда - время
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
    func calculateRouteByDeparture(departure: NSDate, direction: Int, campus: Dictionary<String, AnyObject>) {
        
        //self.direction = direction
        //self.campus = campus
        //self.when = when
        //if when == nil {
        //    self.when = NSDate().dateByAddingTimeInterval(600) // сейчас + 10 минут на сборы
        //}
        
        //if campus == nil {
        //    route = [RouteStep(type: .None)]
        //    return
        //}
        
        let dorm = dormitories![0] // общежитие

        route = [RouteStep]() // очистка маршрута
        
        let timestamp = departure.dateByAddingMinute(10)! // 10 минут на сборы

        if direction == 0 {
            // из Дубков
            
            // общая информация о пути
            let way = RouteStep(type: .Total)
            way.from = dorm["title"] as? String
            way.to = campus["title"] as? String
            route.append(way)
           
            // Маршрут: Автобус->Переход->Электричка->Переход->Метро->Пешком

            // автобусом
            let bus = getNearestBusByDeparture(timestamp, from: "Дубки", to: "Одинцово")
            route.append(bus)
            
            // станции метро
            var subwayFrom: String?     // станция метро после транзита
            var transitArrival: NSDate? // время пребытия к метро
            
            if bus.to == "Славянский бульвар" {
                // станции метро

                subwayFrom = "slavyansky_bulvar"
                // переход Автобус->Метро
                let transit = RouteStep(type: .Transition)
                transit.from = NSLocalizedString("Bus", comment: "") // "Автобус"
                transit.to = bus.to
                transit.duration = 5
                transit.departure = bus.arrival
                transit.arrival = transit.departure.dateByAddingMinute(transit.duration)!
                if transit.duration > 0 {
                    route.append(transit)
                }
                
                // время прибытия
                transitArrival = transit.arrival
           } else {
                // станции ж/д
                let stationFrom = stations![(dorm["station"] as? String)!] as! Dictionary<String, AnyObject>
                let stationTo = stations![(campus["station"] as? String)!] as! Dictionary<String, AnyObject>
                
                // переход Автобус->Станция
                let transit1 = RouteStep(type: .Transition)
                transit1.from = NSLocalizedString("Bus", comment: "") // "Автобус"
                transit1.to = NSLocalizedString("Station", comment: "") // "Станция"
                transit1.duration = stationFrom["transit"] as! Int
                transit1.departure = bus.arrival
                transit1.arrival = transit1.departure.dateByAddingMinute(transit1.duration)!
                if transit1.duration > 0 {
                    route.append(transit1)
                }
                
                // электричкой
                let train = getNearestTrainByDeparture(transit1.arrival, from: stationFrom, to: stationTo)
                route.append(train)
                
                // станции метро
                subwayFrom = stationTo["subway"] as? String
                
                // переход Станция->Метро
                let transit2 = RouteStep(type: .Transition)
                transit2.from = stationTo["title"] as? String
                transit2.to = subways![subwayFrom!] as? String
                transit2.duration = stationTo["transit"] as! Int
                transit2.departure = train.arrival
                transit2.arrival = transit2.departure.dateByAddingMinute(transit2.duration)!
                if transit2.duration > 0 {
                    route.append(transit2)
                }
                
                // время прибытия
                transitArrival = transit2.arrival
            }

            // на метро
            let subwayTo = campus["subway"] as? String
            let subway = getNearestSubwayByDeparture(transitArrival!, from: subwayFrom!, to: subwayTo!)
            route.append(subway)
            
            // пешком
            let onfoot = getNearestOnFootByDeparture(subway.arrival, edu: campus)
            route.append(onfoot)
            
            // форматирование информации о пути
            way.departure = bus.departure.dateByAddingMinute(-10)! // 10 минут на сборы
            way.arrival = onfoot.arrival
            way.duration = Int(way.arrival.timeIntervalSinceDate(way.departure) / 60.0)
            
        } else {
            // в Дубки

            // общая информация о пути
            let way = RouteStep(type: .Total)
            way.from = campus["title"] as? String
            way.to = dorm["title"] as? String
            route.append(way)
            
            // Маршрут: Пешком->Метро->Переход->Электричка->Переход->Автобус

            // пешком
            let onfoot = getNearestOnFootByDeparture(timestamp, edu: campus)
            route.append(onfoot)
            
            // станции ж/д
            let stationFrom = stations![(campus["station"] as? String)!] as! Dictionary<String, AnyObject>
            
            // на метро
            let subwayFrom = campus["subway"] as? String
            let subwayTo = stationFrom["subway"] as? String
            let subway = getNearestSubwayByDeparture(onfoot.arrival, from: subwayFrom!, to: subwayTo!)
            route.append(subway)

            //TODO: добавить обработку автобуса от м.Славянский бульвар
            
            // переход Метро->Станция
            let transit1 = RouteStep(type: .Transition)
            transit1.from = subways![subwayTo!] as? String
            transit1.to = stationFrom["title"] as? String
            transit1.duration = stationFrom["transit"] as! Int
            transit1.departure = subway.arrival
            transit1.arrival = transit1.departure.dateByAddingMinute(transit1.duration)!
            if transit1.duration > 0 {
                route.append(transit1)
            }

            //электричкой
            let stationTo = stations![(dorm["station"] as? String)!] as! Dictionary<String, AnyObject>
            let train = getNearestTrainByDeparture(transit1.arrival, from: stationFrom, to: stationTo)
            route.append(train)

            // переход Станция->Автобус
            let transit2 = RouteStep(type: .Transition)
            transit2.from = NSLocalizedString("Station", comment: "") // "Станция"
            transit2.to = NSLocalizedString("Bus", comment: "") // "Автобус"
            transit2.duration = stationTo["transit"] as! Int
            transit2.departure = train.arrival
            transit2.arrival = transit2.departure.dateByAddingMinute(transit2.duration)!
            if transit2.duration > 0 {
                route.append(transit2)
            }

            // автобусом
            let bus = getNearestBusByDeparture(transit2.arrival, from: "Одинцово", to: "Дубки")
            route.append(bus)
            
            // форматирование информации о пути
            way.departure = onfoot.departure
            way.arrival = bus.arrival
            way.duration = Int(way.arrival.timeIntervalSinceDate(way.departure) / 60.0)
        }
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
    func calculateRouteByArrival(arrival: NSDate, direction: Int, campus: Dictionary<String, AnyObject>) {
        let dorm = dormitories![0] // общежитие
        
        route = [RouteStep]() // очистка маршрута
        
        let timestamp = arrival.dateByAddingMinute(-10)! // прибыть за 10 минут до нужного времени

        if direction == 0 {
            // из Дубков
            
            // общая информация о пути
            let way = RouteStep(type: .Total)
            way.from = dorm["title"] as? String
            way.to = campus["title"] as? String
            route.append(way)
            
            // Маршрут: Автобус->Переход->Электричка->Переход->Метро->Пешком

            // станции ж/д
            let stationFrom = stations![(dorm["station"] as? String)!] as! Dictionary<String, AnyObject>
            let stationTo = stations![(campus["station"] as? String)!] as! Dictionary<String, AnyObject>

            // станции метро
            let subwayFrom = stationTo["subway"] as? String
            let subwayTo = campus["subway"] as? String

            // пешком
            let onfoot = getNearestOnFootByArrival(timestamp, edu: campus)
            
            // на метро
            let subway = getNearestSubwayByArrival(onfoot.departure, from: subwayFrom!, to: subwayTo!)
            
            // переход Станция->Метро
            let transit2 = RouteStep(type: .Transition)
            transit2.from = stationTo["title"] as? String
            transit2.to = subways![subwayFrom!] as? String
            transit2.duration = stationTo["transit"] as! Int
            transit2.departure = subway.departure.dateByAddingMinute(-transit2.duration)!
            transit2.arrival = subway.departure

            // электричкой
            let train = getNearestTrainByArrival(transit2.departure, from: stationFrom, to: stationTo)

            // Коррекция времени отправления и прибытия в зависимости от расписания электрички
            transit2.departure = train.arrival
            transit2.arrival = transit2.departure.dateByAddingMinute(transit2.duration)!
            
            subway.departure = transit2.arrival
            subway.arrival = subway.departure.dateByAddingMinute(subway.duration)!
            
            onfoot.departure = subway.arrival
            onfoot.arrival = onfoot.departure.dateByAddingMinute(onfoot.duration)!
            
            // переход Автобус->Станция
            let transit1 = RouteStep(type: .Transition)
            transit1.from = NSLocalizedString("Bus", comment: "") // "Автобус"
            transit1.to = NSLocalizedString("Station", comment: "") // "Станция"
            transit1.duration = stationFrom["transit"] as! Int
            transit1.departure = train.departure.dateByAddingMinute(-transit1.duration)!
            transit1.arrival = train.departure

            // автобусом
            let bus = getNearestBusByArrival(transit1.departure, from: "Дубки", to: "Одинцово")

            // форматирование информации о пути
            route.append(bus)
            if transit1.duration > 0 {
                route.append(transit1)
            }
            route.append(train)
            if transit2.duration > 0 {
                route.append(transit2)
            }
            route.append(subway)
            route.append(onfoot)
            way.departure = bus.departure.dateByAddingMinute(-10)! // 10 минут на сборы
            way.arrival = onfoot.arrival
            way.duration = Int(way.arrival.timeIntervalSinceDate(way.departure) / 60.0)
            
        } else {
            // в Дубки
            
            // общая информация о пути
            let way = RouteStep(type: .Total)
            way.from = campus["title"] as? String
            way.to = dorm["title"] as? String
            route.append(way)
            
            // Маршрут: Пешком->Метро->Переход->Электричка->Переход->Автобус

            // станции ж/д
            let stationFrom = stations![(campus["station"] as? String)!] as! Dictionary<String, AnyObject>
            let stationTo = stations![(dorm["station"] as? String)!] as! Dictionary<String, AnyObject>

            // станции метро
            let subwayFrom = campus["subway"] as? String
            let subwayTo = stationFrom["subway"] as? String

            // автобусом
            let bus = getNearestBusByArrival(timestamp, from: "Одинцово", to: "Дубки")
            
            // переход Станция->Автобус
            let transit2 = RouteStep(type: .Transition)
            transit2.from = NSLocalizedString("Station", comment: "") // "Станция"
            transit2.to = NSLocalizedString("Bus", comment: "") // "Автобус"
            transit2.duration = stationTo["transit"] as! Int
            transit2.departure = bus.departure.dateByAddingMinute(-transit2.duration)!
            transit2.arrival = bus.departure

            //электричкой
            let train = getNearestTrainByArrival(transit2.departure, from: stationFrom, to: stationTo)

            // переход Метро->Станция
            let transit1 = RouteStep(type: .Transition)
            transit1.from = subways![subwayTo!] as? String
            transit1.to = stationFrom["title"] as? String
            transit1.duration = stationFrom["transit"] as! Int
            transit1.departure = train.departure.dateByAddingMinute(-transit1.duration)!
            transit1.arrival = train.departure

            // на метро
            let subway = getNearestSubwayByArrival(transit1.departure, from: subwayFrom!, to: subwayTo!)
            
            // пешком
            let onfoot = getNearestOnFootByArrival(subway.departure, edu: campus)
            
            // TODO: можно попробовать подобрать автобус после прибытия электрички
            
            // форматирование информации о пути
            route.append(onfoot)
            route.append(subway)
            if transit1.duration > 0 {
                route.append(transit1)
            }
            route.append(train)
            if transit2.duration > 0 {
                route.append(transit2)
            }
            route.append(bus)
            way.departure = onfoot.departure.dateByAddingMinute(-10)! // 10 минут на сборы
            way.arrival = bus.arrival
            way.duration = Int(way.arrival.timeIntervalSinceDate(way.departure) / 60.0)
        }
    }
    
    // MARK: - Route On Bus

    /**
    Returns the nearest bus by departure time
    
    Args:
        from(String): place of departure
        to(String): place of arrival
        departure(NSDate): time of departure
    
    Note:
        'from' and 'to' should not be equal and should be in {'Одинцово', 'Дубки'}
    */
    func getNearestBusByDeparture(departure: NSDate, from: String, to: String, useAsterisk: Bool = true) -> RouteStep {
        // from and to should be in {'Одинцово', 'Дубки'}
        let vals = ["Одинцово", "Дубки"]
        //assert from in {'Одинцово', 'Дубки'}
        assert(vals.contains(from))
        //assert to in {'Одинцово', 'Дубки'}
        assert(vals.contains(to))
        //assert(from != to)
        assert(from != to, "From equal To")
        
        // получить расписание автобуса (время отправления)
        let times = scheduleService.getScheduleBus(from, to: to, timestamp: departure)
        
        if times == nil || times!.count == 0 {
            //TODO: добавить сообщение об ошибки пользователю
            print("Не получилось загрузить расписание автобуса")
            return RouteStep()
        }
 
        // поиск ближайшего рейса (минимум ожидания)
        var minInterval: Double = 24*60*60 // мин. интервал (сутки)
        var busDeparture: NSDate?          // время отправления
        var slBlvdBus: Bool = false        // автобус до м.Славянский бульвара

        for time in times! {
            var timeWithoutAsteriks = time
            // asterisk indicates bus arrival/departure station is 'Славянский бульвар'
            // it needs special handling
            if time.containsString("*") {
                if !useAsterisk { continue } // не использовать автобус до м. Славянский бульвар
                timeWithoutAsteriks = time.substringToIndex(time.endIndex.predecessor())
            }
            let departureTime = departure.dateByWithTime(timeWithoutAsteriks)!
            let interval: Double = departureTime.timeIntervalSinceDate(departure)
            //TODO: # FIXME works incorrectly between weekday 6-7-1
            if interval > 0 && interval < minInterval {
                minInterval = interval
                busDeparture = departureTime
                slBlvdBus = time.containsString("*")
            }
        }
        if busDeparture == nil {
            //print("Ближайший автобус не найден")
            // get nearest bus on next day
            let newDeparture = departure.dateByAddingDay(1)!.dateByWithTime("00:00")!
            return getNearestBusByDeparture(newDeparture, from: from, to: to)
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
        bus.departure = busDeparture!
        //TODO: # FIXME: more real arrival time?
        bus.arrival = bus.departure.dateByAddingMinute(bus.duration)!
        
        return bus
    }

    /**
     Returns the nearest bus by arrival time
     
     Args:
     from(String): place of departure
     to(String): place of arrival
     arrival(NSDate): time of arrival
     
     Note:
     'from' and 'to' should not be equal and should be in {'Одинцово', 'Дубки'}
     */
    func getNearestBusByArrival(arrival: NSDate, from: String, to: String, useAsterisk: Bool = true) -> RouteStep {
        // получить расписание автобуса (время отправления)
        let times = scheduleService.getScheduleBus(from, to: to, timestamp: arrival)
        
        if times == nil || times!.count == 0 {
            //TODO: добавить сообщение об ошибки пользователю
            print("Не получилось загрузить расписание автобуса")
            return RouteStep()
        }
        
        let bus: RouteStep = RouteStep(type: .Bus)
        
        bus.from = from
        bus.to = to
        bus.duration = 15 // время автобуса в пути

        // поиск ближайшего рейса (минимум ожидания)
        var minInterval: Double = 24*60*60 // мин. интервал (сутки)
        var busDeparture: NSDate?          // время отправления
        //var slBlvdBus: Bool = false        // автобус до м.Славянский бульвара
        
        for time in times! {
            var timeWithoutAsteriks = time
            // asterisk indicates bus arrival/departure station is 'Славянский бульвар'
            // it needs special handling
            if time.containsString("*") {
                if !useAsterisk { continue } // не использовать автобус до м. Славянский бульвар
                timeWithoutAsteriks = time.substringToIndex(time.endIndex.predecessor())
            }
            let departureTime = arrival.dateByWithTime(timeWithoutAsteriks)!
            let arrivalTime = departureTime.dateByAddingMinute(bus.duration)! // duration = 15 minute
            let interval: Double = arrival.timeIntervalSinceDate(arrivalTime)
            //TODO: # FIXME works incorrectly between weekday 6-7-1
            if interval > 0 && interval < minInterval {
                minInterval = interval
                busDeparture = departureTime
                //slBlvdBus = time.containsString("*")
            }
        }
        if busDeparture == nil {
            //print("Ближайший автобус не найден")
            // get nearest bus on next day
            let newArrival = arrival.dateByAddingDay(-1)!.dateByWithTime("23:59")!
            return getNearestBusByArrival(newArrival, from: from, to: to)
        }
        
        bus.departure = busDeparture!
        //TODO: # FIXME: more real arrival time?
        bus.arrival = bus.departure.dateByAddingMinute(bus.duration)!
        
        return bus
    }
    
    // MARK: - Route On Train

    /*
    A module which calculates the nearest train using an external API (Yandex.Rasp)
    Note that developer key for Yandex.Rasp is required (stored in .train_api_key)
    Also caches a schedule for today and two days later for faster access
    Key location and cached schedules' files are likely to change in future
    */

    /*
    Returns the nearest train by departure time
    
    Args:
        from(Dictionary): place of departure
        to(Dictionary): place of arrival
        departure(NSDate): time of departure
    
    Note:
        'from' and 'to' should not be equal and should be in STATIONS
    */
    func getNearestTrainByDeparture(departure: NSDate, from: Dictionary<String, AnyObject>, to: Dictionary<String, AnyObject>) -> RouteStep {
        //assert _from in STATIONS
        //assert _to in STATIONS
        
        let fromCode = from["code"] as? String
        let toCode = to["code"] as? String
        
        // получить расписание электричек
        let trains = scheduleService.getScheduleTrain(fromCode!, to: toCode!, timestamp: departure)
        
        if trains == nil || trains!.count == 0 {
            //TODO: добавить сообщение об ошибки пользователю
            print("Не получилось загрузить расписание электричек")
            return RouteStep()
        }

        // поиск ближайшего рейса (минимум ожидания)
        var minInterval: Double = 24*60*60 // мин. интервал (сутки)
        var trainInfo: JSON? // найденая информация о поезде
        for train in trains!.array! {
            let departureTime = train["departure"].string!.date()
            let interval: Double = departureTime!.timeIntervalSinceDate(departure)
            if interval > 0 && interval < minInterval {
                minInterval = interval
                trainInfo = train
            }
        }

        if trainInfo == nil {
            //print("Ближайшая электричка не найдена")
            // get nearest train on next day
            let newDeparture = departure.dateByAddingDay(1)!.dateByWithTime("00:00")!
            return getNearestTrainByDeparture(newDeparture, from: from, to: to)
        }
        
        let train: RouteStep = RouteStep(type: .Train)
        
        train.from = from["title"] as? String
        train.to = to["title"] as? String
        train.trainName = trainInfo!["title"].string //"Кубинка 1 - Москва (Белорусский вокзал)"
        train.stops = trainInfo!["stops"].string //"везде"
        train.departure = trainInfo!["departure"].string!.date()!
        train.arrival = trainInfo!["arrival"].string!.date()!
        train.duration = Int(train.arrival.timeIntervalSinceDate(train.departure) / 60)
        //train.duration = trainInfo!["duration"].int! / 60
        train.url = "https://rasp.yandex.ru/"
        
        return train
    }

    /*
    Returns the nearest train by arrival time
    
    Args:
    from(Dictionary): place of departure
    to(Dictionary): place of arrival
    arrival(NSDate): time of arrival
    
    Note:
    'from' and 'to' should not be equal and should be in STATIONS
    */
    func getNearestTrainByArrival(arrival: NSDate, from: Dictionary<String, AnyObject>, to: Dictionary<String, AnyObject>) -> RouteStep {
        //assert _from in STATIONS
        //assert _to in STATIONS
        
        let fromCode = from["code"] as? String
        let toCode = to["code"] as? String
        
        // получить расписание электричек
        let trains = scheduleService.getScheduleTrain(fromCode!, to: toCode!, timestamp: arrival)
        
        if trains == nil || trains!.count == 0 {
            //TODO: добавить сообщение об ошибки пользователю
            print("Не получилось загрузить расписание электричек")
            return RouteStep()
        }
        
        // поиск ближайшего рейса (минимум ожидания)
        var minInterval: Double = 24*60*60 // мин. интервал (сутки)
        var trainInfo: JSON? // найденая информация о поезде
        for train in trains!.array! {
            let arrivalTime = train["arrival"].string!.date()!
            let interval: Double = arrival.timeIntervalSinceDate(arrivalTime)
            if interval > 0 && interval < minInterval {
                minInterval = interval
                trainInfo = train
            }
        }
        
        if trainInfo == nil {
            //print("Ближайшая электричка не найдена")
            // get nearest train on next day
            let newArrival = arrival.dateByAddingDay(-1)!.dateByWithTime("23:59")!
            return getNearestTrainByArrival(newArrival, from: from, to: to)
        }
        
        let train: RouteStep = RouteStep(type: .Train)
        
        train.from = from["title"] as? String
        train.to = to["title"] as? String
        train.trainName = trainInfo!["title"].string //"Кубинка 1 - Москва (Белорусский вокзал)"
        train.stops = trainInfo!["stops"].string //"везде"
        train.departure = trainInfo!["departure"].string!.date()!
        train.arrival = trainInfo!["arrival"].string!.date()!
        train.duration = Int(train.arrival.timeIntervalSinceDate(train.departure) / 60)
        //train.duration = trainInfo!["duration"].int! / 60
        train.url = "https://rasp.yandex.ru/"
        
        return train
    }

    // MARK: - Route On Subway

    // Subway Route Data (timedelta in minutes)
    let subwayDuration = [
        "kuntsevskaya": [ // Кунцевская
            "strogino":           16, // Строгино
            "semyonovskaya":      28, // Семёновская
            "kurskaya":           21, // Курская
            "leninsky_prospekt" : 28  // Ленинский проспект
        ],
        "belorusskaya": [ // Белорусская
            "aeroport":  6, // Аэропорт
            "tverskaya": 4  // Тверская
        ],
        "begovaya": [ // Беговая
            "tekstilshchiki": 23, // Текстильщики
            "lubyanka":       12, // Лубянка
            "shabolovskaya":  20, // Шаболовская
            "kuznetsky_most":  9, // Кузнецкий мост
            "paveletskaya":   17, // Павелецкая
            "kitay-gorod":    11  // Китай-город
        ],
        "slavyansky_bulvar": [ // Славянский бульвар
            "strogino":          18, // Строгино
            "semyonovskaya":     25, // Семёновская
            "kurskaya":          18, // Курская
            "leninsky_prospekt": 25, // Ленинский проспект
            "aeroport":          26, // Аэропорт
            "tverskaya":         22, // Тверская
            "tekstilshchiki":    35, // Текстильщики
            "lubyanka":          21, // Лубянка
            "shabolovskaya":     22, // Шаболовская
            "kuznetsky_most":    22, // Кузнецкий мост
            "paveletskaya":      17, // Павелецкая
            "kitay-gorod":       20  // Китай-город
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
    Returns the nearest subway route by departure time
    
    Args:
        from(String): Russian name of station of departure
        to(String): Russian name of station of arrival
        departure(NSDate): time of departure
    
    Note:
        'from' and 'to' must exist in SUBWAY_DATA.keys or any of SUBWAY_DATA[key].values
    */
    func getNearestSubwayByDeparture(departure: NSDate, from: String, to: String) -> RouteStep {
        let subway: RouteStep = RouteStep(type: .Subway)

        subway.from = subways![from] as? String
        subway.to = subways![to] as? String
        subway.duration = getSubwayDuration(from, to: to)

        let subwayCloses = departure.dateByWithTime(subwayClosesTime)
        let subwayOpens = departure.dateByWithTime(subwayOpensTime)
        // subwayCloses <= timestamp <= subwayOpens
        if subwayCloses!.compare(departure) != .OrderedDescending
            && departure.compare(subwayOpens!) != .OrderedDescending {
            // subway is still closed
            subway.departure = subwayOpens!
        } else {
            subway.departure = departure
        }
        subway.arrival = subway.departure.dateByAddingMinute(subway.duration)!
        
        return subway
    }

    /**
     Returns the nearest subway route by arrival time
     
     Args:
     from(String): Russian name of station of departure
     to(String): Russian name of station of arrival
     arrival(NSDate): time of arrival
     
     Note:
     'from' and 'to' must exist in SUBWAY_DATA.keys or any of SUBWAY_DATA[key].values
     */
    func getNearestSubwayByArrival(arrival: NSDate, from: String, to: String) -> RouteStep {
        let subway: RouteStep = RouteStep(type: .Subway)
        
        subway.from = subways![from] as? String
        subway.to = subways![to] as? String
        subway.duration = getSubwayDuration(from, to: to)
        
        let subwayCloses = arrival.dateByWithTime(subwayClosesTime)
        let subwayOpens = arrival.dateByWithTime(subwayOpensTime)
        // subwayCloses <= timestamp <= subwayOpens
        if subwayCloses!.compare(arrival) != .OrderedDescending
            && arrival.compare(subwayOpens!) != .OrderedDescending {
                // subway is still closed
                subway.departure = subwayOpens!
                subway.arrival = subwayOpens!.dateByAddingMinute(subway.duration)!
        } else {
            subway.departure = arrival.dateByAddingMinute(-subway.duration)!
            subway.arrival = arrival
        }
        subway.arrival = subway.departure.dateByAddingMinute(subway.duration)!
        
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
    Returns the nearest onfoot route by departure time
    
    Args:
        edu(Dictionary): place of arrival
        departure(NSDate): time of departure from subway exit
    
    Note:
        'edu' should be a value from EDUS
    */
    func getNearestOnFootByDeparture(departure: NSDate, edu: Dictionary<String, AnyObject>) -> RouteStep {
        let onfoot: RouteStep = RouteStep(type: .Onfoot)
        
        onfoot.duration = edu["onfoot"] as! Int
        onfoot.departure = departure
        onfoot.arrival = departure.dateByAddingMinute(onfoot.duration)!
        //onfoot.map = formMapUrl(edu["mapsrc"] as! String)
        onfoot.map = (edu["name"] as! String) + ".png"
        
        return onfoot
    }    

    /**
     Returns the nearest onfoot route by arrival time
     
     Args:
     edu(Dictionary): place of arrival
     arrival(NSDate): time of arrival from campus exit
     
     Note:
     'edu' should be a value from EDUS
     */
    func getNearestOnFootByArrival(arrival: NSDate, edu: Dictionary<String, AnyObject>) -> RouteStep {
        let onfoot: RouteStep = RouteStep(type: .Onfoot)
        
        onfoot.duration = edu["onfoot"] as! Int
        onfoot.departure = arrival.dateByAddingMinute(-onfoot.duration)!
        onfoot.arrival = arrival
        //onfoot.map = formMapUrl(edu["mapsrc"] as! String)
        onfoot.map = (edu["name"] as! String) + ".png"
        
        return onfoot
    }
}
