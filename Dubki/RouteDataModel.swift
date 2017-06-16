//
//  RouteDataModel.swift
//  Dubki
//
//  Created by Alexander Morenko on 30.10.15.
//  Copyright © 2015-2017 LionSoft, LLC. All rights reserved.
//

import UIKit

class RouteDataModel: NSObject {
    
    // Singleton Class
    static let sharedInstance = RouteDataModel()

    // Описание общежитий
    let dormitories = NSArray(contentsOfFile: Bundle.main.path(forResource: "Dormitories", ofType: "plist")!) as? [Dictionary<String, AnyObject>]
    // Описание кампусов
    let campuses = NSArray(contentsOfFile: Bundle.main.path(forResource: "Campuses", ofType: "plist")!) as? [Dictionary<String, AnyObject>]
    // Названия станций метро
    let subways = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Subways", ofType: "plist")!) as? Dictionary<String, AnyObject>
    // Описания станций ж/д
    let stations = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Stations", ofType: "plist")!) as? Dictionary<String, AnyObject>
    
    // Маршрут
    var route: [RouteStep] = [RouteStep()]
    
    override init() {
        super.init()
        
        // load array of campuses from resource
        //let dormitoriesPath = Bundle.main.path(forResource: "Dormitories", ofType: "plist")
        //let dormitories = NSArray(contentsOfFile: dormitoriesPath!)
        //print(dormitories?.count)
        
    }
    
    /**
    Calculates a route as if timestamp is the time of departure
    
    Args:
        direction (Int): flow from/to dormitory
        campus (Dictionary): place edu of arrival/departure
        timestamp(Optional[Date]): time of departure.
            Defaults to the current time plus 10 minutes.
        src(Optional[str]): function caller ID (used for logging)
    
    Returns:
        route (Array): a calculated route
    */
    func calculateRouteByDeparture(_ departure: Date, direction: Int, campus: Dictionary<String, AnyObject>) {
        
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
            // Маршрут: Автобус->Переход->Электричка->Переход->Метро->Пешком

            // автобусом
            let bus = BusStep(departure: timestamp, from: "Дубки", to: "Одинцово")
            
            // станции метро
            var subwayFrom: String?     // станция метро после транзита
            var transitArrival: Date? // время пребытия к метро
            
            var transit1: TransitionStep?
            var train: TrainStep?
            var transit2: TransitionStep?
            
            if bus.to == "Славянский бульвар" {
                // станции метро

                subwayFrom = "slavyansky_bulvar"
                // переход Автобус->Метро
                let transitFrom = NSLocalizedString("Bus", comment: "") // "Автобус"
                let transitTo = bus.to!
                transit1 = TransitionStep(departure: bus.arrival, from: transitFrom, to: transitTo, duration: 5) // 5 minute
                
                // время прибытия
                transitArrival = transit1!.arrival
           } else {
                // станции ж/д
                let stationFrom = stations![(dorm["station"] as? String)!] as! Dictionary<String, AnyObject>
                let stationTo = stations![(campus["station"] as? String)!] as! Dictionary<String, AnyObject>
                
                // переход Автобус->Станция
                let t1From = NSLocalizedString("Bus", comment: "") // "Автобус"
                let t1To = NSLocalizedString("Station", comment: "") // "Станция"
                let t1Duration = stationFrom["transit"] as! Int
                transit1 = TransitionStep(departure: bus.arrival, from: t1From, to: t1To, duration: t1Duration)
                
                // электричкой
                train = TrainStep(departure: transit1!.arrival, from: stationFrom, to: stationTo)
                
                // станции метро
                subwayFrom = stationTo["subway"] as? String
                
                // переход Станция->Метро
                let t2From = stationTo["title"] as! String
                let t2To = subways![subwayFrom!] as! String
                let t2Duration = stationTo["transit"] as! Int
                transit2 = TransitionStep(departure: train!.arrival, from: t2From, to: t2To, duration: t2Duration)
                
                // время прибытия
                transitArrival = transit2!.arrival
            }

            // на метро
            let subwayTo = campus["subway"] as? String
            let subway = SubwayStep(departure: transitArrival!, from: subwayFrom!, to: subwayTo!)
            
            // пешком
            let onfoot = OnfootStep(departure: subway.arrival, edu: campus)
            
            // общая информация о пути
            let wayFrom = dorm["title"] as! String
            let wayTo = campus["title"] as! String
            let wayDeparture = bus.departure.dateByAddingMinute(-10)! // 10 минут на сборы
            let wayArrival = onfoot.arrival
            let way = TotalStep(from: wayFrom, to: wayTo, departure: wayDeparture, arrival: wayArrival)
            
            // формирование информации о пути
            route.append(way)
            route.append(bus)
            if transit1!.duration > 0 {
                route.append(transit1!)
            }
            if train != nil {
                route.append(train!)
            }
            if transit2 != nil && transit2!.duration > 0 {
                route.append(transit2!)
            }
            route.append(subway)
            route.append(onfoot)
        } else {
            // в Дубки
            // Маршрут: Пешком->Метро->Переход->Электричка->Переход->Автобус

            // станции ж/д
            let stationFrom = stations![(campus["station"] as? String)!] as! Dictionary<String, AnyObject>
            let stationTo = stations![(dorm["station"] as? String)!] as! Dictionary<String, AnyObject>
            
            // станции метро
            let subwayFrom = campus["subway"] as? String
            let subwayTo = stationFrom["subway"] as? String
            
            // пешком
            let onfoot = OnfootStep(departure: timestamp, edu: campus)
            
            // на метро
            let subway = SubwayStep(departure: onfoot.arrival, from: subwayFrom!, to: subwayTo!)

            //TODO: добавить обработку автобуса от м.Славянский бульвар
            
            // переход Метро->Станция
            let t1From = subways![subwayTo!] as! String
            let t1To = stationFrom["title"] as! String
            let t1Duration = stationFrom["transit"] as! Int
            let transit1 = TransitionStep(departure: subway.arrival, from: t1From, to: t1To, duration: t1Duration)

            //электричкой
            let train = TrainStep(departure: transit1.arrival, from: stationFrom, to: stationTo)

            // переход Станция->Автобус
            let t2From = NSLocalizedString("Station", comment: "") // "Станция"
            let t2To = NSLocalizedString("Bus", comment: "") // "Автобус"
            let t2Duration = stationTo["transit"] as! Int
            let transit2 = TransitionStep(departure: train.arrival, from: t2From, to: t2To, duration: t2Duration)

            // автобусом
            let bus = BusStep(departure: transit2.arrival, from: "Одинцово", to: "Дубки")
            
            // общая информация о пути
            let wayFrom = campus["title"] as! String
            let wayTo = dorm["title"] as! String
            let wayDeparture = onfoot.departure
            let wayArrival = bus.arrival
            let way = TotalStep(from: wayFrom, to: wayTo, departure: wayDeparture, arrival: wayArrival)

            // формирование информации о пути
            route.append(way)
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
        }
    }

    /**
     Calculates a route as if timestamp is the time of arrival
     
     Args:
     direction (Int): flow from/to dormitory
     campus (Dictionary): place edu of arrival/departure
     timestampEnd(Date): expected time of arrival
     
     Returns:
     route (Array): a calculated route
     */
    func calculateRouteByArrival(_ arrival: Date, direction: Int, campus: Dictionary<String, AnyObject>) {
        let dorm = dormitories![0] // общежитие
        
        route = [RouteStep]() // очистка маршрута
        
        let timestamp = arrival.dateByAddingMinute(-10)! // прибыть за 10 минут до нужного времени

        if direction == 0 {
            // из Дубков
            // Маршрут: Автобус->Переход->Электричка->Переход->Метро->Пешком

            // станции ж/д
            let stationFrom = stations![(dorm["station"] as? String)!] as! Dictionary<String, AnyObject>
            let stationTo = stations![(campus["station"] as? String)!] as! Dictionary<String, AnyObject>

            // станции метро
            let subwayFrom = stationTo["subway"] as? String
            let subwayTo = campus["subway"] as? String

            // пешком
            let onfoot = OnfootStep(arrival: timestamp, edu: campus)
            
            // на метро
            let subway = SubwayStep(arrival: onfoot.departure, from: subwayFrom!, to: subwayTo!)
            
            // переход Станция->Метро
            let t2From = stationTo["title"] as! String
            let t2To = subways![subwayFrom!] as! String
            let t2Duration = stationTo["transit"] as! Int
            let transit2 = TransitionStep(arrival: subway.departure, from: t2From, to: t2To, duration: t2Duration)

            // электричкой
            let train = TrainStep(arrival: transit2.departure, from: stationFrom, to: stationTo)

            // Коррекция времени отправления и прибытия в зависимости от расписания электрички
            transit2.departure = train.arrival
            transit2.arrival = transit2.departure.dateByAddingMinute(transit2.duration)!
            
            subway.departure = transit2.arrival
            subway.arrival = subway.departure.dateByAddingMinute(subway.duration)!
            
            onfoot.departure = subway.arrival
            onfoot.arrival = onfoot.departure.dateByAddingMinute(onfoot.duration)!
            
            // переход Автобус->Станция
            let t1From = NSLocalizedString("Bus", comment: "") // "Автобус"
            let t1To = NSLocalizedString("Station", comment: "") // "Станция"
            let t1Duration = stationFrom["transit"] as! Int
            let transit1 = TransitionStep(arrival: train.departure, from: t1From, to: t1To, duration: t1Duration)

            // автобусом
            let bus = BusStep(arrival: transit1.departure, from: "Дубки", to: "Одинцово")

            // общая информация о пути
            let wayFrom = dorm["title"] as! String
            let wayTo = campus["title"] as! String
            let wayDeparture = bus.departure.dateByAddingMinute(-10)! // 10 минут на сборы
            let wayArrival = onfoot.arrival
            let way = TotalStep(from: wayFrom, to: wayTo, departure: wayDeparture, arrival: wayArrival)

            // формирование информации о пути
            route.append(way)
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
            
        } else {
            // в Дубки
            // Маршрут: Пешком->Метро->Переход->Электричка->Переход->Автобус

            // станции ж/д
            let stationFrom = stations![(campus["station"] as? String)!] as! Dictionary<String, AnyObject>
            let stationTo = stations![(dorm["station"] as? String)!] as! Dictionary<String, AnyObject>

            // станции метро
            let subwayFrom = campus["subway"] as? String
            let subwayTo = stationFrom["subway"] as? String

            // автобусом
            let bus = BusStep(arrival: timestamp, from: "Одинцово", to: "Дубки")
            
            // переход Станция->Автобус
            let t2From = NSLocalizedString("Station", comment: "") // "Станция"
            let t2To = NSLocalizedString("Bus", comment: "") // "Автобус"
            let t2Duration = stationTo["transit"] as! Int
            let transit2 = TransitionStep(arrival: bus.departure, from: t2From, to: t2To, duration: t2Duration)

            //электричкой
            let train = TrainStep(arrival: transit2.departure, from: stationFrom, to: stationTo)

            // переход Метро->Станция
            let t1From = subways![subwayTo!] as! String
            let t1To = stationFrom["title"] as! String
            let t1Duration = stationFrom["transit"] as! Int
            let transit1 = TransitionStep(arrival: train.departure, from: t1From, to: t1To, duration: t1Duration)

            // на метро
            let subway = SubwayStep(arrival: transit1.departure, from: subwayFrom!, to: subwayTo!)
            
            // пешком
            let onfoot = OnfootStep(arrival: subway.departure, edu: campus)
            
            // TODO: можно попробовать подобрать автобус после прибытия электрички
            
            // общая информация о пути
            let wayFrom = campus["title"] as! String
            let wayTo = dorm["title"] as! String
            let wayDeparture = onfoot.departure.dateByAddingMinute(-10)! // 10 минут на сборы
            let wayArrival = bus.arrival
            let way = TotalStep(from: wayFrom, to: wayTo, departure: wayDeparture, arrival: wayArrival)
            
            // формирование информации о пути
            route.append(way)
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
        }
    }
    
}
