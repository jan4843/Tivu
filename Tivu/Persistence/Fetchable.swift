import CoreData

protocol Fetchable {
    associatedtype R: NSFetchRequestResult
    
    init(result: R)
}

struct MappedFetchResults<F: Fetchable>: Equatable, RandomAccessCollection {
    private let results: NSArray
    
    init(_ results: NSArray = NSArray()) {
        self.results = results
    }
    
    var count: Int { results.count }
    var startIndex: Int { 0 }
    var endIndex: Int { count }
    
    subscript(position: Int) -> F {
        let object = results.object(at: position) as! F.R
        return F(result: object)
    }
}
