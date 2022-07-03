extension Date {
    func withinLast(_ interval: TimeInterval) -> Bool {
        DateInterval(start: self, duration: interval).contains(Date.now)
    }
}
