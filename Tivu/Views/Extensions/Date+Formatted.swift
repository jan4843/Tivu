extension Date {
    var formattedTimeLeft: String {
        let left = self.timeIntervalSince1970 - Date.now.timeIntervalSince1970
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: left + 60)!
    }
}
