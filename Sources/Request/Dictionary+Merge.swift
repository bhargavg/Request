
extension Dictionary {
	func merge(with dict: Dictionary<Key, Value>) -> Dictionary<Key, Value> {
		var copyOfSelf = self
		for (key, value) in dict {
			copyOfSelf.updateValue(value, forKey: key)
		}
		return copyOfSelf
	}
}

