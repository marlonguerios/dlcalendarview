//
//  DLCalendarView.swift
//  DefiniteList
//
//  Created by Marlon Guerios on 2019-12-13.
//  Copyright © 2019 inohaus Consulting. All rights reserved.
//

import SwiftUI
import DLExtensions

struct DLCalendarConstants {
    struct font {
        static let dayFont = Font.system(size: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body).pointSize-2)
        static let selectedDayFont = Font.system(size: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body).pointSize-2)
        static let weekNumberFont = Font.system(size: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .footnote).pointSize-2)
        static let dayOfWeekFont = Font.system(size: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .footnote).pointSize-3)
        static let currentMonth = Font.system(size: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .footnote).pointSize)

    }

}

struct DLCalendarView: View {
    
    @Binding var selectedDate: Date

    @State var currentMonth: Int
    @State var currentYear: Int
    @Binding var showCalendar: Bool
    @State var refresh: Bool = false
    var flaggedDays: [Int]?
    
    typealias MonthChange = ((Int, Int)->Void)
    @State var onMonthChangeAction: MonthChange?
    
    public func onMonthChange(perform action: @escaping MonthChange) -> some View {
        return DLCalendarView(selectedDate: self.$selectedDate, currentMonth: self.currentMonth, currentYear: self.currentYear, showCalendar: self.$showCalendar, refresh: self.refresh, flaggedDays: self.flaggedDays, onMonthChangeAction: action)
    }
    
    
    fileprivate func getDayCell(_ day: Int) -> some View {
        var comp = DateComponents()
        comp.day = day
        comp.month = self.currentMonth
        comp.year = self.currentYear
        let date = Calendar.current.date(from: comp)!
        let isWeekend = Calendar.current.isDateInWeekend(date)
        let isToday = Calendar.current.isDateInToday(date)
        
        let isFlagged = flaggedDays != nil && flaggedDays!.contains(day) && !self.isSelectedDate(day: day, selectedDate: self.selectedDate)
        
        return DLCalendarCell(text: String(day), isFlagged: isFlagged)
            .font(self.isSelectedDate(day: day, selectedDate: self.selectedDate) ? DLCalendarConstants.font.selectedDayFont : DLCalendarConstants.font.dayFont)
            .foregroundColor(isToday ? .red : (isWeekend ? .secondary : .primary))
            .padding(0)
            .onTapGesture {
                self.selectedDate = self.getSelectedDate(day: day, month: self.currentMonth, year: self.currentYear)
        }
    }
    
    var body: some View {
        VStack(spacing: 3) {
            HStack {
                HStack {
                    Image(systemName: "chevron.left").imageScale(.large)
                        .foregroundColor(.primary)
                        .onTapGesture {
                            if self.currentMonth == 1 {
                                self.currentMonth = 12
                                self.currentYear -= 1
                            } else {
                                self.currentMonth -= 1
                            }
                            if self.onMonthChangeAction != nil {
                                self.onMonthChangeAction!(self.currentMonth, self.currentYear)
                            }
                        self.refresh.toggle()

                    }
                }.padding([.horizontal])
                Spacer()
                Text("\(Calendar.current.monthSymbols[self.currentMonth-1]) \(String(self.currentYear))").font(DLCalendarConstants.font.currentMonth)
                    .onTapGesture {
                        self.currentMonth = Calendar.current.component(.month, from: Date())
                        self.currentYear = Calendar.current.component(.year, from: Date())
                        self.selectedDate = Date()
                }
                Spacer()
                HStack {
                    Image(systemName: "chevron.right").imageScale(.large)
                        .foregroundColor(Color.primary)
                        .onTapGesture {
                            if self.currentMonth == 12 {
                                self.currentMonth = 1
                                self.currentYear += 1
                            } else {
                                self.currentMonth += 1
                            }
                            if self.onMonthChangeAction != nil {
                                self.onMonthChangeAction!(self.currentMonth, self.currentYear)
                            }
                            self.refresh.toggle()
                    }
                }.padding([.horizontal])
            }
            HStack(spacing: 2) {
                Spacer().frame(width: 15)
                    DLCalendarCell(text: "\(Calendar.current.weekdaySymbols[0].prefix(3).uppercased())").font(DLCalendarConstants.font.dayOfWeekFont).foregroundColor(.secondary)
                        .frame(width: (UIScreen.main.bounds.width-45)/7)
                    DLCalendarCell(text: "\(Calendar.current.weekdaySymbols[1].prefix(3).uppercased())").font(DLCalendarConstants.font.dayOfWeekFont).foregroundColor(.secondary)
                        .frame(width: (UIScreen.main.bounds.width-45)/7)
                    DLCalendarCell(text: "\(Calendar.current.weekdaySymbols[2].prefix(3).uppercased())").font(DLCalendarConstants.font.dayOfWeekFont).foregroundColor(.secondary)
                        .frame(width: (UIScreen.main.bounds.width-45)/7)
                    DLCalendarCell(text: "\(Calendar.current.weekdaySymbols[3].prefix(3).uppercased())").font(DLCalendarConstants.font.dayOfWeekFont).foregroundColor(.secondary)
                        .fixedSize().frame(width: (UIScreen.main.bounds.width-45)/7)
                    DLCalendarCell(text: "\(Calendar.current.weekdaySymbols[4].prefix(3).uppercased())").font(DLCalendarConstants.font.dayOfWeekFont).foregroundColor(.secondary)
                        .frame(width: (UIScreen.main.bounds.width-45)/7)
                    DLCalendarCell(text: "\(Calendar.current.weekdaySymbols[5].prefix(3).uppercased())").font(DLCalendarConstants.font.dayOfWeekFont).foregroundColor(.secondary)
                        .frame(width: (UIScreen.main.bounds.width-45)/7)
                    DLCalendarCell(text: "\(Calendar.current.weekdaySymbols[6].prefix(3).uppercased())").font(DLCalendarConstants.font.dayOfWeekFont).foregroundColor(.secondary)
                        .frame(width: (UIScreen.main.bounds.width-45)/7)
            }.frame(height: 20)
            HStack(spacing: 2) {
                    self.getNumberOfWeekCell(week: 1, month: self.currentMonth, year: self.currentYear).fixedSize().frame(width: 15)
                    ForEach(self.getWeekOfMonth(week: 1, month: self.currentMonth, year: self.currentYear), id: \.self) { day in
                        self.getDayCell(day).fixedSize().frame(width: (UIScreen.main.bounds.width-45)/7)
                            .padding([.vertical], 2)
                            .contentShape(Rectangle())
                            .overlay(RoundedRectangle(cornerRadius: 20)
                                        .stroke(self.isSelectedDate(day: day, selectedDate: self.selectedDate) ? Color.secondary : Color(UIColor.clear), lineWidth: 1))
                    }
                }.fixedSize().frame(height: 20)
            HStack(spacing: 2) {
                    self.getNumberOfWeekCell(week: 2, month: self.currentMonth, year: self.currentYear).fixedSize().frame(width: 15)
                    ForEach(self.getWeekOfMonth(week: 2, month: self.currentMonth, year: self.currentYear), id: \.self) { day in
                        self.getDayCell(day).fixedSize().frame(width: (UIScreen.main.bounds.width-45)/7)
                        .padding([.vertical], 2)
                        .contentShape(Rectangle())
                            .overlay(RoundedRectangle(cornerRadius: 20)
                                        .stroke(self.isSelectedDate(day: day, selectedDate: self.selectedDate) ? Color.secondary : Color(UIColor.clear), lineWidth: 1))
                    }
                }.fixedSize().frame(height: 20)
            HStack(spacing: 2) {
                    self.getNumberOfWeekCell(week: 3, month: self.currentMonth, year: self.currentYear).fixedSize().frame(width: 15)
                    ForEach(self.getWeekOfMonth(week: 3, month: self.currentMonth, year: self.currentYear), id: \.self) { day in
                        self.getDayCell(day).fixedSize().frame(width: (UIScreen.main.bounds.width-45)/7)
                        .padding([.vertical], 2)
                        .contentShape(Rectangle())
                            .overlay(RoundedRectangle(cornerRadius: 20)
                                        .stroke(self.isSelectedDate(day: day, selectedDate: self.selectedDate) ? Color.secondary : Color(UIColor.clear), lineWidth: 1))
                    }
                }.fixedSize().frame(height: 20)
            HStack(spacing: 2) {
                    self.getNumberOfWeekCell(week: 4, month: self.currentMonth, year: self.currentYear).fixedSize().frame(width: 15)
                    ForEach(self.getWeekOfMonth(week: 4, month: self.currentMonth, year: self.currentYear), id: \.self) { day in
                        self.getDayCell(day).fixedSize().frame(width: (UIScreen.main.bounds.width-45)/7)
                        .padding([.vertical], 2)
                        .contentShape(Rectangle())
                            .overlay(RoundedRectangle(cornerRadius: 20)
                                        .stroke(self.isSelectedDate(day: day, selectedDate: self.selectedDate) ? Color.secondary : Color(UIColor.clear), lineWidth: 1))
                    }
                }.fixedSize().frame(height: 20)
            if self.getWeekOfMonth(week: 5, month: self.currentMonth, year: self.currentYear)[0] != 0 {
                HStack(spacing: 2) {
                    self.getNumberOfWeekCell(week: 5, month: self.currentMonth, year: self.currentYear).fixedSize().frame(width: 15)
                    ForEach(self.getWeekOfMonth(week: 5, month: self.currentMonth, year: self.currentYear), id: \.self) { day in
                        self.getDayCell(day).fixedSize().frame(width: (UIScreen.main.bounds.width-45)/7)
                        .padding([.vertical], 2)
                        .contentShape(Rectangle())
                            .overlay(RoundedRectangle(cornerRadius: 20)
                                        .stroke(self.isSelectedDate(day: day, selectedDate: self.selectedDate) ? Color.secondary : Color(UIColor.clear), lineWidth: 1))
                    }
                }.fixedSize().frame(height: 20)
            }
            if self.getWeekOfMonth(week: 6, month: self.currentMonth, year: self.currentYear)[0] != 0 {
                HStack(spacing: 2) {
                    self.getNumberOfWeekCell(week: 6, month: self.currentMonth, year: self.currentYear).fixedSize().frame(width: 15)
                    ForEach(self.getWeekOfMonth(week: 6, month: self.currentMonth, year: self.currentYear), id: \.self) { day in
                        self.getDayCell(day).fixedSize().frame(width: (UIScreen.main.bounds.width-45)/7)
                        .padding([.vertical], 2)
                        .contentShape(Rectangle())
                            .overlay(RoundedRectangle(cornerRadius: 20)
                                        .stroke(self.isSelectedDate(day: day, selectedDate: self.selectedDate) ? Color.secondary : Color(UIColor.clear), lineWidth: 1))
                    }
                }.fixedSize().frame(height: 20)
            }
        }
            .gesture(self.getDragGesture())
    }
    
    func getDragGesture() -> _EndedGesture<_ChangedGesture<DragGesture>> {
        let drag = DragGesture()
        return drag
            .onChanged({ (value: DragGesture.Value) in
                if value.predictedEndTranslation.height < 0 && (value.predictedEndTranslation.width > -60 && value.predictedEndTranslation.width < 60)  {
                    // going up
                    withAnimation(.easeInOut) {
                        self.showCalendar = false
                    }
                } else {

                }
            }).onEnded({ (value: DragGesture.Value) in
                if (value.predictedEndTranslation.width > 60 || value.predictedEndTranslation.width < -60) && value.predictedEndTranslation.height > -30 {
                    if value.predictedEndTranslation.width < 0 {
                        // right
                        if self.currentMonth == 12 {
                            self.currentMonth = 1
                            self.currentYear += 1
                        } else {
                            self.currentMonth += 1
                        }
                    } else {
                        // left
                        if self.currentMonth == 1 {
                            self.currentMonth = 12
                            self.currentYear -= 1
                        } else {
                            self.currentMonth -= 1
                        }
                    }
                    if self.onMonthChangeAction != nil {
                        self.onMonthChangeAction!(self.currentMonth, self.currentYear)
                    }
                    self.refresh.toggle()
                }
            })
    }
    
    func getSelectedDate(day: Int, month: Int, year: Int) -> Date {
        var comp = DateComponents()
        comp.day = day
        comp.month = month
        comp.year = year
        return Calendar.current.date(from: comp)!
    }
    
    func isSelectedDate(day: Int, selectedDate: Date) -> Bool {
        let selectedMonth = Calendar.current.component(.month, from: selectedDate)
        let selectedYear = Calendar.current.component(.year, from: selectedDate)
        let selectedDay = Calendar.current.component(.day, from: selectedDate)
        return day == selectedDay && self.currentMonth == selectedMonth && self.currentYear == selectedYear
    }
    
    
    func getWeekOfMonth(week: Int, month: Int, year: Int) -> [Int] {
        var days: [Int] = []
        var components = DateComponents()
        components.day = 1
        components.month = month
        components.year = year
        let firstDay = Calendar.current.date(from: components)!
        let firstWeekDay = Calendar.current.component(.weekday, from: firstDay)
        
        if week == 1 {
            for index in 1...7 {
                if index >= firstWeekDay {
                    days.append((index - firstWeekDay + 1))
                } else {
                    days.append(0)
                }
            }
        } else {
            for index in 1...7 {
                var day = (7*(week-1))-firstWeekDay+index+1
                if day > Calendar.current.component(.day, from: firstDay.endOfMonth) {
                    day = 0
                }
                days.append(day)
            }
        }
        
        return days
    }
    
    func getNumberOfWeek(week: Int, month: Int, year: Int) -> Int {
        var numberOfWeek = 1
        var components = DateComponents()
        components.day = 1
        components.month = month
        components.year = year
        let firstDay = Calendar.current.date(from: components)!
        
        if week == 1 {
            numberOfWeek = Calendar.current.component(.weekOfYear, from: firstDay)
        } else {
            let date = Calendar.current.date(bySetting: .weekOfMonth, value: week, of: firstDay)!
            numberOfWeek = Calendar.current.component(.weekOfYear, from: date)
        }
        return numberOfWeek
    }
    
    func getNumberOfWeekCell(week: Int, month: Int, year: Int) -> some View {
        let weekNumber = self.getNumberOfWeek(week: week, month: month, year: year)
        return VStack {
            Text(String(weekNumber)).font(DLCalendarConstants.font.weekNumberFont).foregroundColor(.secondary)
        }.frame(width: 15).padding([.vertical], 3)
    }
    
}


struct DLCalendarCell: View {
    
    var text: String
    var isFlagged: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            if self.text == "0" {
                Text("").fixedSize().frame(width: 20)
            } else {
                    ZStack {
                        Text(self.text).fixedSize().frame(width: 20)
                        if self.isFlagged {
                            Circle().frame(width: 4, height: 4).foregroundColor(.red).offset(x: 0, y: 9)
                        }
                    }.padding(0)
            }
        }.frame(minWidth: 10, maxWidth: .infinity).padding([.vertical], 1)
    }
    
}

struct DLCalendar_Preview: PreviewProvider {
    static var previews: some View {
        DLCalendarView(selectedDate: .constant(Date()), currentMonth: 8, currentYear: 2020, showCalendar: .constant(true))
    }
}
