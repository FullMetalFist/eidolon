import UIKit
import ReactiveCocoa

class ListingsCountdownManager: NSObject {
   
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var countdownContainerView: UIView!
    let formatter = NSNumberFormatter()

    dynamic var sale: Sale?

    let time = SystemTime()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        formatter.minimumIntegerDigits = 2

        time.syncSignal().dispatchAsyncMainScheduler().take(1).subscribeNext { [weak self] (_) in
            self?.startTimer()
            self?.setLabelsHidden(false)
        }
    }

    func setFonts() {
        (countdownContainerView.subviews as! [UIView]).map{ (view) -> () in
            if let label = view as? UILabel {
                label.font = UIFont.serifFontWithSize(15)
            }
        }
        countdownLabel.font = UIFont.sansSerifFontWithSize(20)
    }

    func setLabelsHidden(hidden: Bool) {
        countdownContainerView.hidden = hidden
    }

    func setLabelsHiddenIfSynced(hidden: Bool) {
        if time.inSync() {
            setLabelsHidden(hidden)
        }
    }

    func hideDenomenatorLabels() {
        for subview in countdownContainerView.subviews as! [UIView] {
            subview.hidden = subview != countdownLabel
        }
    }

    func startTimer() {
        let timer = NSTimer(timeInterval: 0.49, target: self, selector: "tick:", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)

        self.tick(timer)
    }
    
    func tick(timer: NSTimer) {
        if let sale = sale {
            if time.inSync() == false { return }
            if sale.id == "" { return }

            if sale.isActive(time) {
                let now = time.date()
                let flags: NSCalendarUnit = .CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond
                let components = NSCalendar.currentCalendar().components(flags, fromDate: now, toDate: sale.endDate, options: nil)
                
                self.countdownLabel.text = "\(formatter.stringFromNumber(components.hour)!) : \(formatter.stringFromNumber(components.minute)!) : \(formatter.stringFromNumber(components.second)!)"

            } else {
                self.countdownLabel.text = "CLOSED"
                hideDenomenatorLabels()
                timer.invalidate()
            }
        }
    }
}
