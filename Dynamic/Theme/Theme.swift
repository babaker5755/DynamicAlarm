//
//  Theme.swift
//  Dynamic
//
//  Created by Brandon Baker on 4/29/20.
//  Copyright © 2020 Brandon Baker. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialDialogs

//theme
// 61 / 90/ 128
// 152 / 193 / 217
// 224 / 251/ 252
// 238 / 108 / 77
//41 / 50 / 65

//1080 1920
//FCBBA6 or EE6C4D
//E0FBFC wh
//98C1D9 lb
// 3D5A80 db
// 293241 ddb


extension UIColor {
    
    static let themeWhite = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.00) // pure white
    static let theme1 = UIColor(red: 61/255, green: 90/255, blue: 128/255, alpha: 1.0) // darker blue
    static let theme2 = UIColor(red: 152/255, green: 193/255, blue: 217/255, alpha: 1.0) // lighter bluer
    static let theme3 = UIColor(red: 224/255, green: 251/255, blue: 252/255, alpha: 1.0) // almost white
    static let theme4 = UIColor(red: 238/255, green: 108/255, blue: 77/255, alpha: 1.0) // orange
    static let theme5 = UIColor(red: 41/255, green: 50/255, blue: 65/255, alpha: 1.0) // darkest blue
    
    static let background = UIColor(red: 66/255, green: 66/255, blue: 80/255, alpha: 1)
    static let foreground = UIColor(red: 51/255, green: 51/255, blue: 60/255, alpha: 1)
    static let primaryForeground = UIColor(red:0.22, green:0.22, blue:0.25, alpha:1.00)
    static let primary = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.00)//UIColor(red: 55/255, green: 239/255, blue: 186/255, alpha: 1)
    static let thirdly = UIColor(red:0.12, green:0.73, blue:0.50, alpha:1.00)
    static let forthly = UIColor(red:0.00, green:0.49, blue:0.32, alpha:1.00)
    
    static let blackText = UIColor(red: 41/255, green: 50/255, blue: 65/255, alpha: 1.0)//UIColor.black
    
    static let grayText = UIColor(red:0.37, green:0.37, blue:0.40, alpha:1.00)
    
    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
}

extension NSMutableAttributedString {
    
    @discardableResult func light(_ text: String) -> NSMutableAttributedString {
        let font = UIFont.systemFont(ofSize: 18, weight: .light)
        
        let attrs: [NSAttributedString.Key: Any] = [.font: font, NSAttributedString.Key.foregroundColor : UIColor.themeWhite.withAlphaComponent(0.7) ]
        let normal = NSMutableAttributedString(string:text, attributes: attrs)
        append(normal)
        return self
    }
    
    @discardableResult func bold(_ text: String) -> NSMutableAttributedString {
        let font = UIFont.systemFont(ofSize: 18, weight: .bold)
        let attrs: [NSAttributedString.Key: Any] = [.font: font, NSAttributedString.Key.foregroundColor : UIColor.themeWhite ]
        let normal = NSMutableAttributedString(string:text, attributes: attrs)
        append(normal)
        return self
    }
    
    @discardableResult func customText(_ text: String, font: UIFont, color: UIColor = UIColor.black.lighter(by: 15)!) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: font, NSAttributedString.Key.foregroundColor : color as Any ]
        let normal = NSMutableAttributedString(string:text, attributes: attrs)
        append(normal)
        return self
    }
    
}


extension UIFont {
    static let avinerMedium = UIFont(name: "Avenir-Medium", size: 22)!
    static let monoFur = UIFont(name: "MonofurboldForPowerline", size: 40)
    
}
extension Double {
    public func isBetween(lower: Double, upper: Double) -> Bool {
        return lower <= self && self <= upper
    }
    public func getString(_ decimals: Int = 2) -> String {
        return String(format: "%.\(decimals)f", self)
    }
}

extension Date {
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow:  Date { return Date().dayAfter }
    static var today : Date { return Date().noon }
    
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: midnight)!
    }
    
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: midnight)!
    }
    
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    
    var midnight : Date {
        return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
    }
    
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
    
    func getString(time: Bool = false) -> String {
        let dateFormatter = DateFormatter()
        if time {
            dateFormatter.dateFormat = "hh:mm a"
        } else {
            dateFormatter.calendar = Calendar(identifier: .iso8601)
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        }
        return dateFormatter.string(from: self)
    }
    
}
extension String {
    func getTimeAsString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        let date = dateFormatter.date(from: self)
        return date?.getString(time: true) ?? ""
    }
}

class Helpers {
    static func addGuidelines(_ view: UIView) {
        _ = view.subviews.map {
            _ = $0.subviews.map {
                _ = $0.subviews.map {
                    _ = $0.subviews.map {
                        $0.layer.borderColor = UIColor.white.cgColor
                        $0.layer.borderWidth = 1
                    }
                    $0.layer.borderColor = UIColor.white.cgColor
                    $0.layer.borderWidth = 1
                }
                $0.layer.borderColor = UIColor.white.cgColor
                $0.layer.borderWidth = 1
            }
            $0.layer.borderColor = UIColor.white.cgColor
            $0.layer.borderWidth = 1
        }
    }
}
