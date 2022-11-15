package base

#Compound: {
	in: {...}
	_deps: {...}
	for _, resources in _deps {
		out: resources.out
	}
}
