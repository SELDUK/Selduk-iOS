//
//  MainViewController.swift
//  Seldeog
//
//  Created by 권준상 on 2022/03/14.
//

import UIKit
import SnapKit
import Then

final class CalendarViewController: BaseViewController {
    
    var yearLabel = UILabel().then {
        $0.textColor = .black
        $0.font = UIFont.nanumPen(size: 15, family: .bold)
    }
    
    var monthLabel = UILabel().then {
        $0.textColor = .black
        $0.font = UIFont.nanumPen(size: 35, family: .bold)
    }
    
    var calendarView: CalendarView!
    
    var datePicker = UIDatePicker()
    
    lazy var numberOfWeeks: Int = Date.numberOfWeeksInMonth(Date())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        calendarView = CalendarView()
        calendarView.cvc = self
        setLayout()
        
        let myStyle = CalendarView.Style()

        myStyle.cellShape                = .round
        myStyle.cellColorDefault         = UIColor.clear
        myStyle.cellColorToday           = UIColor(red:1.00, green:0.84, blue:0.64, alpha:1.00)
        myStyle.cellSelectedBorderColor  = UIColor.clear
        myStyle.cellSelectedColor        = UIColor.clear
        myStyle.cellEventColor           = UIColor.clear
        myStyle.headerTextColor          = UIColor.black
        myStyle.headerHeight             = 45

        myStyle.cellTextColorDefault     = UIColor.black
        myStyle.cellTextColorToday       = UIColor.black
        myStyle.cellColorOutOfRange      = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        myStyle.cellSelectedTextColor    = UIColor.black

        myStyle.headerBackgroundColor    = UIColor.white
        myStyle.weekdaysBackgroundColor  = UIColor.white
        myStyle.firstWeekday             = .sunday
        myStyle.locale                   = Locale(identifier: "en_US")

        myStyle.cellFont = UIFont.systemFont(ofSize: 16, weight: .heavy)
        myStyle.headerFont = UIFont.systemFont(ofSize: 17, weight: .bold)
        myStyle.weekdaysFont = UIFont.systemFont(ofSize: 16, weight: .heavy)

        calendarView.style = myStyle

        calendarView.dataSource = self
        calendarView.delegate = self
        calendarView.direction = .horizontal
        calendarView.multipleSelectionEnable = false
        calendarView.marksWeekends = true

        calendarView.backgroundColor = UIColor.white

        let today = Date()
        self.calendarView.selectDate(today)
        self.calendarView.setDisplayDate(today)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        yearLabel.text = dateFormatter.string(from: today).uppercased()
        
        dateFormatter.dateFormat = "MMMM"
        monthLabel.text = dateFormatter.string(from: today)

        dateFormatter.dateFormat = "yyyy-MM"
        let yearMonth = dateFormatter.string(from: today)
        calendarView.yearMonth = yearMonth
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let today = Date()
        
        self.datePicker.locale = self.calendarView.style.locale
        self.datePicker.timeZone = self.calendarView.calendar.timeZone
        self.datePicker.setDate(today, animated: false)
    }
    
}

extension CalendarViewController: CalendarViewDataSource {
    func headerString(_ date: Date) -> String? {
        return ""
    }

    func startDate() -> Date {
        var dateComponents = DateComponents()
        dateComponents.month = -12

        let today = Date()
        let threeMonthsAgo = self.calendarView.calendar.date(byAdding: dateComponents, to: today)!

        return threeMonthsAgo
    }

    func endDate() -> Date {
        var dateComponents = DateComponents()
        dateComponents.month = 12

        let today = Date()
        let twoYearsFromNow = self.calendarView.calendar.date(byAdding: dateComponents, to: today)!

        return twoYearsFromNow
    }
}

extension CalendarViewController: CalendarViewDelegate {
    
    func calendar(_ calendar: CalendarView, didSelectDate date : Date, withEvents events: [CalendarEvent]) {
           
           print("Did Select: \(date) with \(events.count) events")
           for event in events {
               print("\t\"\(event.title)\" - Starting at:\(event.startDate)")
           }
           
       }
       
       func calendar(_ calendar: CalendarView, didScrollToMonth date : Date) {
           print(self.calendarView.selectedDates)
           self.datePicker.setDate(date, animated: true)
       }
}

extension CalendarViewController {
    private func setLayout() {
        let safeArea = view.safeAreaLayoutGuide

        view.addSubviews(yearLabel, monthLabel, calendarView)
        
        yearLabel.snp.makeConstraints {
            $0.top.equalTo(safeArea).offset(10)
            $0.centerX.equalToSuperview()
        }
        
        monthLabel.snp.makeConstraints {
            $0.top.equalTo(yearLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
        
        calendarView.snp.makeConstraints {
            $0.top.equalTo(monthLabel.snp.bottom).offset(25)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(self.view.frame.size.width + 30)
        }
    }
}
