function mapAssertDefined(overide, source, citation) {
  const map = overide || {};
  for (let key in source) {
    map[key] = map[key] || []
    map[key].push(citation)
  }
}

class metaParser {
  constructor(meta) {
    const root = {}
    const lookup = {}
    const symbolMap = {}
    const typesets = meta.typesets;
    for (let attribute in typesets) {
      const typeset = typesets[attribute]

      
      lookup[attribute] = typeset;
      if (typeset.superset) {
        for (let superAttribute in typeset.superset) {
          const superset = lookup[superAttribute]
          if (!superset.subset) {
            superset.subset = []
          }
          superset.subset.push(typeset)
        }
      } else {
        root.push(typeset)
      }
    }
  }
}
