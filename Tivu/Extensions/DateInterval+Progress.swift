extension DateInterval {
    var currentProgress: Double {
        let start = self.start.timeIntervalSince1970
        let now = Date.now.timeIntervalSince1970
        
        let elapsed = now - start
        let total = self.duration
        
        guard elapsed > 0, total > 0 else { return 0 }
        return min(elapsed / total, 1)
    }
}
