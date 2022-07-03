extension Program {
    var formattedSubtitle: String? {
        var result: String?
        if let subtitle = subtitle {
            result = subtitle
        }
        if let number = number?.description {
            if result == nil {
                result = number
            } else {
                result! += " (\(number))"
            }
        }
        return result
    }
    
    var formattedInterval: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        
        let start = interval.start.formatted(date: .omitted, time: .shortened)
        let duration = formatter.string(from: interval.duration)!
        return "\(start) • \(duration)"
    }
}
