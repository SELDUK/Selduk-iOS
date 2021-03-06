//
//  MainViewController.swift
//  Seldeog
//
//  Created by 권준상 on 2022/03/14.
//

import UIKit
import SnapKit
import Then
import PanModal
import Kingfisher

protocol MoveCalendarDate {
    func setCalendarDate(date: Date)
}

final class CalendarViewController: BaseViewController {
    
    var charactersForCalendar: [UserCharacterImage] = [] {
        didSet {
            self.calendarView.reloadData()
        }
    }
    
    var yearLabel = UILabel().then {
        $0.textColor = .black
        $0.font = UIFont.nanumPen(size: 15, family: .bold)
    }
    
   var monthLabel = UILabel().then {
        $0.textColor = .black
        $0.font = UIFont.nanumPen(size: 35, family: .bold)
    }
    
    private let selectMonthButton = UIButton().then {
        $0.setImage(Image.arrowDownIcon, for: .normal)
    }
    
    private let blackBackgroundView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    
    private let calendarTabBarView = CalendarTabBarView()
    private let selectColorView = SelectColorView()
    private var calendarView: CalendarView!
    private var datePicker = UIDatePicker()
    
    private lazy var numberOfWeeks: Int = Date.numberOfWeeksInMonth(Date())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        calendarTabBarView.calendarButton.setImage(Image.calendarIconClicked, for: .normal)
        calendarTabBarView.calendarButton.setTitleColor(.white, for: .normal)
        calendarView = CalendarView()
        calendarView.cvc = self
        setLayout()
        registerTarget()
        
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
        myStyle.cellTextColorToday       = UIColor.white
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

        setCalendarDate()
        getMyCharacter()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setCalendarDate()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let today = Date()
        
        self.datePicker.locale = self.calendarView.style.locale
        self.datePicker.timeZone = self.calendarView.calendar.timeZone
        self.datePicker.setDate(today, animated: false)
    }
    
    func setCalendarDate(date: Date? = Date()) {
        self.calendarView.setDisplayDate(date ?? Date())

        yearLabel.text = date?.toYear() ?? Date().toYear()
        monthLabel.text = date?.toMonth().uppercased() ?? Date().toMonth().uppercased()
        let yearMonth = date?.toYearMonth() ?? Date().toYearMonth()
        calendarView.yearMonth = yearMonth
        
        getCharacterForCalendar(date: yearMonth)
    }
    
    private func registerTarget() {
        [selectMonthButton, calendarTabBarView.writeComplimentButton, calendarTabBarView.aboutMeButton, calendarTabBarView.selfLoveButton, calendarTabBarView.settingButton, selectColorView.navyColor, selectColorView.yellowColor, selectColorView.pinkColor, selectColorView.mauveColor, selectColorView.greenColor].forEach {
            $0.addTarget(self, action: #selector(buttonTapAction(_:)), for: .touchUpInside)
        }
    }
    
    private func setNavigationBackgroundBlack() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationController?.navigationBar.tintColor = UIColor.black
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
    
    private func resetNavigationBackground() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = nil
        navigationController?.navigationBar.tintColor = UIColor.black
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
    
    private func resetView() {
        blackBackgroundView.removeFromSuperview()
        selectColorView.alpha = 0.0
    }
    
    private func showSelectColorView() {
        setNavigationBackgroundBlack()
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
        tapGesture.delegate = self
                
        blackBackgroundView.addGestureRecognizer(tapGesture)
        view.addSubview(blackBackgroundView)
        blackBackgroundView.addSubview(selectColorView)
        
        blackBackgroundView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        selectColorView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(calendarTabBarView.snp.top)
            $0.width.equalTo(270)
            $0.height.equalTo(110)
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseIn, animations: { self.selectColorView.alpha = 1.0 }, completion: nil)
    }
    
    private func getComplimentList() {
        let today = Date()
        
        getTodayComplimentList(date: today.toString()) { data in
            if data.success {
                self.navigationController?.pushViewController(TodayComplimentViewController(), animated: false)
            } else {
                self.showToastMessageAlert(message: "칭찬 리스트 로드에 실패하였습니다.")
            }
        }
    }
    
    private func getTodayComplimentList(
        date: String,
        completion: @escaping (ComplimentListResponse) -> Void
    ) {
        UserRepository.shared.getUserComplimentList(date: date) { result in
            switch result {
            case .success(let response):
                print(response)
                guard let data = response as? ComplimentListResponse else { return }
                completion(data)
            case .dateDoesNotExist:
                self.showSelectColorView()
            default:
                print("API error")
            }
        }
    }
        
    private func makeTodayCharacter(color: Int) {
        makeTodayCharacter(color: color) { data in
            if data.success {
                self.navigationController?.pushViewController(TodayComplimentViewController(), animated: false)
            } else {
                self.showToastMessageAlert(message: "색 선택에 실패하였습니다.")
            }
        }
    }
    
    private func makeTodayCharacter(
        color: Int,
        completion: @escaping (UserResponse) -> Void
    ) {
        UserRepository.shared.createTodayCharacter(color: color) { result in
            switch result {
            case .success(let response):
                print(response)
                guard let data = response as? UserResponse else { return }
                completion(data)
            case .dateDoesNotExist:
                self.showSelectColorView()
            default:
                print("API error")
            }
        }
    }
    
    private func getCharacterForCalendar(date: String) {
        UserRepository.shared.getCharacterForCalendar(date: date) { [weak self] result in
            switch result {
            case .success(let response):
                guard let data = response as? CalendarResponse else { return }
                self?.charactersForCalendar = data.data.usrChrImgs
            case .requestErr(let errorResponse):
                dump(errorResponse)
            default:
                print("calendar getCharacterForCalendar - error")
            }
        }
    }
    
    private func getMyCharacter() {
        UserRepository.shared.getCalendarButton() { [weak self] result in
            switch result {
            case .success(let response):
                print(response)
                guard let data = response as? UserResponse else { return }
                CharacterData.myCharacterURLstring = data.data?.usrChrImgDft
                guard let imgURLString = CharacterData.myCharacterURLstring else { return }
                if let imgURL = URL(string: imgURLString) {
                    do {
                        let data = try Data(contentsOf: imgURL)
                        self?.calendarTabBarView.writeComplimentButton.setBackgroundImage(UIImage(data: data), for: .normal)
                    } catch { print("image error") }
                } else {
                    self?.calendarTabBarView.writeComplimentButton.setImage(Image.navyShapeCircle, for: .normal)
                }
            case .requestErr(let errorResponse):
                dump(errorResponse)
            default:
                print("setMyCharacter - error")
            }
        }
    }
    
}

extension CalendarViewController: CalendarViewDataSource {
    func headerString(_ date: Date) -> String? {
        return ""
    }

    func startDate() -> Date {
        var dateComponents = DateComponents()
        dateComponents.month = -36

        let today = Date()
        let twoYearsAgo = self.calendarView.calendar.date(byAdding: dateComponents, to: today)!

        return twoYearsAgo
    }

    func endDate() -> Date {
        var dateComponents = DateComponents()
        dateComponents.month = 36

        let today = Date()
        let twoYearsFromNow = self.calendarView.calendar.date(byAdding: dateComponents, to: today)!

        return twoYearsFromNow
    }
}

extension CalendarViewController: CalendarViewDelegate {
    
    func calendar(_ calendar: CalendarView, didSelectDate date : Date, withEvents events: [CalendarEvent]) {
        let selectedDate = date.toString()
        let today = Date().toString()
        
        if selectedDate == today {
            getComplimentList()
        } else {
            let selectedDate = date.toString()
            for character in charactersForCalendar {
                if selectedDate == character.usrChrDateCrt {
                    self.navigationController?.pushViewController(PastComplimentViewController(date: selectedDate), animated: false)
                    break
                }
            }
        }
    }
       
    func calendar(_ calendar: CalendarView, didScrollToMonth date : Date) {
        self.datePicker.setDate(date, animated: true)
        getCharacterForCalendar(date: date.toYearMonth())
    }
}

extension CalendarViewController {
    private func setLayout() {
        let safeArea = view.safeAreaLayoutGuide

        view.addSubviews(yearLabel, monthLabel, selectMonthButton, calendarView, calendarTabBarView)
        
        yearLabel.snp.makeConstraints {
            $0.top.equalTo(safeArea)
            $0.centerX.equalToSuperview()
        }
        
        monthLabel.snp.makeConstraints {
            $0.top.equalTo(yearLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
        
        selectMonthButton.snp.makeConstraints {
            $0.centerY.equalTo(monthLabel)
            $0.leading.equalTo(monthLabel.snp.trailing).offset(8)
            $0.width.equalTo(14)
            $0.height.equalTo(9)
        }

        calendarView.snp.makeConstraints {
            $0.top.equalTo(monthLabel.snp.bottom).offset(25)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(self.view.frame.size.width + 30)
        }
                
        calendarTabBarView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(125)
        }
    }
        
    @objc private func buttonTapAction(_ sender: UIButton) {
        switch sender {
        case selectMonthButton:
            let datePickerViewController = DatePickerViewController()
            datePickerViewController.dateDelegate = self
            self.presentPanModal(datePickerViewController)
        case calendarTabBarView.writeComplimentButton:
            getComplimentList()
        case calendarTabBarView.aboutMeButton:
            LoginSwitcher.updateRootVC(root: .aboutMe)
        case calendarTabBarView.selfLoveButton:
            LoginSwitcher.updateRootVC(root: .selfLove)
        case calendarTabBarView.settingButton:
            LoginSwitcher.updateRootVC(root: .setting)
        case selectColorView.navyColor,
            selectColorView.yellowColor,
            selectColorView.pinkColor,
            selectColorView.mauveColor,
            selectColorView.greenColor:
            makeTodayCharacter(color: sender.tag)
            resetView()
        default:
            return
        }
    }
}

extension CalendarViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        resetView()
        return true
    }
}
