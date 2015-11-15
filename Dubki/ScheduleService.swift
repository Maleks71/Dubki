//
//  ScheduleService.swift
//  Dubki
//
//  Created by Игорь Моренко on 13.11.15.
//  Copyright © 2015 LionSoft, LLC. All rights reserved.
//

import UIKit

class ScheduleService: NSObject {

    // Singleton Class
    static let sharedInstance = ScheduleService()

    // API Keys
    let apikeys = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("apikeys", ofType: "plist")!) as? Dictionary<String, String>

    // Standart User Default Settings
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    let BUS_SCHEDULE_FILE = "bus.json"
    let TRAIN_SCHEDULE_FILE = "train.json"

    var busFileURL: NSURL   // путь к файлу bus.json
    var trainFileURL: NSURL // путь к файлу train.json

    var busSchedule: JSON?
    var trainSchedule: JSON?
    var lastUpdate: NSDate? {
        get {
            userDefaults.synchronize()
            return userDefaults.objectForKey("last_update") as? NSDate
        }
        set {
            userDefaults.setObject(newValue, forKey: "last_update")
            userDefaults.synchronize()
        }
    }
    
    // конструктор
    override init() {
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        busFileURL = documentsUrl.URLByAppendingPathComponent(BUS_SCHEDULE_FILE)
        trainFileURL = documentsUrl.URLByAppendingPathComponent(TRAIN_SCHEDULE_FILE)
        
        super.init()

        //let fileManager = NSFileManager.defaultManager()
        //if fileManager.fileExistsAtPath(filePath) {

        // загрузка расписания из файла bus.json
        if let busData = NSData(contentsOfURL: busFileURL) {
            busSchedule = JSON(data: busData)
        }
        // загрузка расписания из файла train.json
        if let trainData = NSData(contentsOfURL: trainFileURL) {
            trainSchedule = JSON(data: trainData)
        }
        
        cacheSchedules()
    }

    // Кэширование расписания автобуса и электрички на сегодня
    func cacheSchedules() {
        if lastUpdate != nil && lastUpdate!.string("yyyyMMdd") == NSDate().string("yyyyMMdd") {
            if busSchedule != nil && trainSchedule != nil {
                return
            }
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        cacheScheduleBus()
        cacheTrainSchedule()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        if busSchedule != nil && trainSchedule != nil {
            // update schedule successfull
            lastUpdate = NSDate()
        }
    }
    
    /*
    Caches a schedule between all stations
    */
    func cacheTrainSchedule() {
        trainSchedule = JSON([String: JSON]())
        let date = NSDate().string("yyyy-MM-dd")
        let from = "c10743" //"Одинцово" = "s9600721"
        let toStations = ["s9601728", "s9600821", "s9601666", "s2000006"] //["Кунцево", "Фили", "Беговая", "Белорусская"]
        for to in toStations {
            if let fromTo = loadScheduleTrain(from, to: to, date: date) {
                let key = "\(from):\(to):\(date)"
                trainSchedule![key] = fromTo
            }
            if let toFrom = loadScheduleTrain(to, to: from, date: date) {
                let key = "\(to):\(from):\(date)"
                trainSchedule![key] = toFrom
            }
        }
        // сохранить в файл train.json
        if let trainData = trainSchedule!.rawString()?.dataUsingEncoding(NSUTF8StringEncoding) {
            trainData.writeToURL(trainFileURL, atomically: true)
        }
    }
    
    // MARK: - Train Schedule

    /*
    Caches a schedule between stations from arguments starting with certain day
    Writes the cached schedule for day and two days later to train_cached_* files
    
    Args:
    from(String): departure train station
    to(String): arrival train station
    timestamp(NSDate): date to cache schedule for
    */
    func loadScheduleTrain(from: String, to: String, date: String) -> JSON? {
        let YANDEX_API_KEY = apikeys!["rasp.yandex.ru"]
        // URL of train schedule API provider
        let TRAIN_API_URL = "https://api.rasp.yandex.net/v1.0/search/?apikey=%@&format=json&date=%@&from=%@&to=%@&lang=ru&transport_types=suburban"
        
        let api_url = String(format: TRAIN_API_URL, YANDEX_API_KEY!, date, from, to)
        
        // загрузка распияния из интернета
        if let trainSchedule = NSData(contentsOfURL: NSURL(string: api_url)!) {
            let schedule = JSON(data: trainSchedule)

            var trains = [Dictionary<String, AnyObject>]()
            for item in (schedule["threads"].array)! {
                var train = Dictionary<String, AnyObject>()
                train["arrival"] = item["arrival"].string
                train["departure"] = item["departure"].string
                train["duration"] = item["duration"].int
                train["stops"] = item["stops"].string
                train["title"] = item["thread"]["title"].string
                train["number"] = item["thread"]["number"].string
                trains.append(train)
            }
            return JSON(trains)
        }
        return nil
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
        cacheSchedules()
        if trainSchedule == nil {
            return nil
        }
        
        let date = timestamp.string("yyyy-MM-dd")
        let key = "\(from):\(to):\(date)"
        if trainSchedule![key].isExists() {
            return trainSchedule![key]
        }
        if let schedule = loadScheduleTrain(from, to: to, date: date) {
            trainSchedule![key] = schedule
            return schedule
        }
        return nil
    }

    // MARK: - Bus Schedule
    
    /**
    Caches the bus schedule to `SCHEDULE_FILE`
    Загрузить расписание автобуса из интернета
    */
    func cacheScheduleBus() {
        let BUS_API_URL = "https://dubkiapi2.appspot.com/sch"
        
        // загрузка распияния из интернета
        if let busData = NSData(contentsOfURL: NSURL(string: BUS_API_URL)!) {
            // сохранить расписание в файл bus.json
            busData.writeToURL(busFileURL, atomically: true)

            busSchedule = JSON(data: busData)
        }
    }
    
    // загрузка расписания автобусов Дубки-Одинцово в файл bus.json
    func getScheduleBus(from: String, to: String, timestamp: NSDate) -> [String]? {
        cacheSchedules()
        if busSchedule == nil {
            return nil
        }
        
        var _from: String = from
        var _to: String = to
        
        // today is either {'', '*Суббота', '*Воскресенье'}
        if timestamp.weekday == 7 {
            if from == "Дубки" {
                _from = "ДубкиСуббота"
            } else if to == "Дубки" {
                _to = "ДубкиСуббота"
            }
        } else if timestamp.weekday == 1 {
            if from == "Дубки" {
                _from = "ДубкиВоскресенье"
            } else if to == "Дубки" {
                _to = "ДубкиВоскресенье"
            }
        }

        var times = [String]() // время отправления автобуса
        // find current schedule
        for elem in busSchedule!.array! {
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
        
        return times
    }
/*
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
*/
}
