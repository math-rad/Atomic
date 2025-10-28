function makeLookup(src) {
  const result = {}
  for (value of src) {
    result[value] = true
  }
}
function generator(meta) {
  const root = {subset: []};
  const lookup = {};

  for (let set of meta.src) {
    set.subset = []
    lookup[set.name] = set

    if (set.discrete) {
      set.discrete.real = set.discrete.src.split(set.discrete.del)
      set.discrete.composition = makeLookup(self.discrete.real.split(''))
    }
    
    if (set.superset) {
      for (let label of set.superset) {
        lookup[label].subset.push(set)
      }
    } else {
      root.subset.push(set)
    }
  }

  for (toplevel of root) {
    
  }
}
