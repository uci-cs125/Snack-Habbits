//
//  TrackingProgressViewController.swift
//  Snack Habbits
//
//  Created by Jony Tucci on 3/6/21.
//  Copyright © 2021 Jony Tucci. All rights reserved.
//

import UIKit
import Charts
import TinyConstraints
import Firebase

class TrackingProgressViewController: UIViewController, ChartViewDelegate {
    
    let dispatchQueue = DispatchQueue(label: "myQueue", qos: .background)
    let semaphore = DispatchSemaphore(value: 0)
    var currentUser: User?
    var totalCalories = [Int]()
    var calorieGoal: Double = 2000.00
    var previousLimit: Double = 2000.00
    var dateLabels = [String](){
        didSet{
            lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dateLabels)
        }
    }
    
    var dates = [String]()
    

    var calorieValues = [ChartDataEntry]()
    
    lazy var lineChartView: LineChartView = {
        let chartView = LineChartView()
        chartView.backgroundColor = .white
        chartView.rightAxis.enabled = false
        chartView.legend.enabled = false
        let yAxis = chartView.leftAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.setLabelCount(6, force: false)
        yAxis.labelTextColor = .black
        yAxis.axisLineColor = .black
        yAxis.labelPosition = .insideChart
        yAxis.drawGridLinesEnabled = false
        
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelFont = .boldSystemFont(ofSize: 12)
        chartView.xAxis.setLabelCount(9, force: true)
        chartView.xAxis.labelTextColor = .black
        chartView.xAxis.axisLineColor = .black
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dateLabels)
        
        let marker:BalloonMarker = BalloonMarker(color: UIColor.black, font: UIFont(name: "Helvetica", size: 12)!, textColor: UIColor.white, insets: UIEdgeInsets(top: 7.0, left: 7.0, bottom: 7.0, right: 7.0))
        marker.minimumSize = CGSize(width: 75.0, height: 35.0)
        chartView.marker = marker
//        chartView.animate(xAxisDuration: 0.5)
        return chartView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        getDates()
        setData()
        view.addSubview(lineChartView)
        lineChartView.fillSuperview(padding: .init(top: 100, left: 0, bottom: 100, right: 0))
        fetchUserMeals()
        
        self.navigationController?.navigationItem.title = "Weekly Progress"
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCalorieGoal()
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
    }
    
    
//    private func updateLineLimit(_ value: Double, label: String) {
//        if let line = lineChartView.leftAxis.limitLines.filter({ $0.label == label }).first {
//            print("Updating limitLine")
//            line.limit = value
//            lineChartView.animate(yAxisDuration: 0.00001)
//        }
//    }
    
    func setData() {
        let gradientColors = [#colorLiteral(red: 0.9961868229, green: 0, blue: 0.3499520317, alpha: 1).cgColor, #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor] as CFArray
        let colorLocations:[CGFloat] = [1.0, 0.0]
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) // Gradient Object
        let set1 = LineChartDataSet(entries: calorieValues, label: "Calories")
        set1.drawCirclesEnabled = false
//        set1.mode = .horizontalBezier
        set1.lineWidth = 3
        set1.setColor(.white)
        set1.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0)
        set1.fillAlpha = 0.8
        set1.drawFilledEnabled = true
        set1.drawHorizontalHighlightIndicatorEnabled = false
        set1.highlightColor  = .red
        
//        self.addLimitLines(limit: Double(calorieGoal))
        
        let data = LineChartData(dataSet: set1)
        data.setDrawValues(false)
        lineChartView.data = data
    }
    

    
    //MARK:- Firestore
    //MARK:- API Service
    fileprivate func fetchCalorieGoal() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        dispatchQueue.async {
            self.fetchCurrentUser(with: uid)
            self.semaphore.wait()
            print("Success Fetched current user for calorie goal")
            self.fetchGoal()
        }
        print("END `Fetched calorie Goal")
    }
    
    private func fetchCurrentUser(with uid: String){
        Firestore.firestore().collection("users").document(uid).getDocument { (documentSnapshot, error) in
            if let error = error {
                self.semaphore.signal()
                print("Error fetching current User:", error)
                return
            }
            
            guard let dictionary = documentSnapshot?.data() else {
                self.semaphore.signal()
                return
            }
            
            self.currentUser = User(dictionary: dictionary)
            self.semaphore.signal()
        } // END Get User

    }
    
    private func fetchUserMeals(){
        let entry = ChartDataEntry(x: Double(0.0), y: Double(0.0))
        self.calorieValues.append(entry)
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("meals").document(uid).getDocument { (documentSnapshot, error) in
            if let error = error {
                print("****Error fetching users meals:", error)
                return
            }

            guard let dictionary = documentSnapshot?.data() else { return }

            for (i, date) in self.dates.enumerated(){
                print("i\(i), date\(date)")
                var totalCals : Float = 0.0
                guard let _ = dictionary[date] else
                {
                    let entry = ChartDataEntry(x: Double(i), y: Double(totalCals))
                    self.calorieValues.append(entry)
                    continue
                }
                let mealDict = dictionary[date]! as! [Any]
                
                
                for meal in mealDict {
                    if let data = try? JSONSerialization.data(withJSONObject: meal, options: []){
                        if let parsedMeal = try? JSONDecoder().decode(Meal.self, from: data) {
                            totalCals += parsedMeal.calories!
                        }
                    }

                }
                
                let entry = ChartDataEntry(x: Double(i), y: Double(Int(totalCals)))
                self.calorieValues.append(entry)
            }
            
            DispatchQueue.main.async {
                self.setData()
            }
        }
    }
    
    func fetchGoal() {
        var calorieRequest = CalorieRequestBody(user: self.currentUser!)
        APIService.shared.fetchCalorieGoal(calorieRequestBody: calorieRequest) { (results, error) in
            if let error = error {
                print("Failed to fetch Calories", error)
                return
            }

            guard let calorieIntake = results?.results[0] else { return }
            self.calorieGoal = Double(calorieIntake)
            DispatchQueue.main.async {
                print("RD CALORIES: \(calorieIntake)")
                self.addLimitLines(limit: (Double(calorieIntake)))
                
            }

        } // END get Recipes
    }
    
    func addLimitLines(limit: Double) {
        if let line = lineChartView.leftAxis.limitLines.filter({ $0.label == "Goal \(Int(previousLimit))" }).first {
            lineChartView.leftAxis.removeLimitLine(line)
        }
        self.previousLimit = limit
        let calorieGoal = ChartLimitLine(limit: limit, label: "Goal \(Int(limit))")
        calorieGoal.lineWidth = 0.5
        calorieGoal.lineColor = #colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1)
        calorieGoal.lineDashLengths = [8.0]
        lineChartView.leftAxis.addLimitLine(calorieGoal)
        lineChartView.animate(yAxisDuration: 0.00001)


    }
    
    func getDates() {
        let cal = Calendar.current
        var date = cal.startOfDay(for: Date())
        var days = [Int]()
        var arrDates = [String]()
        arrDates.append("")
        dates.append("")
        for i in 1 ... 7 {
            let day = cal.component(.day, from: date)
            days.append(day)
            date = cal.date(byAdding: .day, value: -1, to: date)!
            
            let dateFormatter = DateFormatter()
            
            dateFormatter.dateFormat = "MM/dd"
            let dateString = dateFormatter.string(from: date)
            arrDates.append(dateString)
            
            dateFormatter.dateFormat = "YYYY-MM-dd"
            let dateString2 = dateFormatter.string(from: date)
            self.dates.append(dateString2)
        }
        
        arrDates.append("")
        dateLabels = arrDates.reversed()
        dates.append("")
        dates = dates.reversed()
    }
}
