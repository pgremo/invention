$(document).ready ->
  $('#name')
  .typeahead
      hint: true,
      highlight: true,
      minLength: 3
    ,
      name: 'types',
      displayKey: 'value',
      source: (q, cb) ->
        $.get '/api/typeLookup', query: q, (data) ->
          cb data.map (x) -> id: x[0], value: x[1]
  .on 'typeahead:selected', (event, data) ->
    $.get "/api/bom/#{data.id}", (data) ->
      g = new dagreD3.Digraph()

      recur = (x, visited) ->
        if visited.indexOf(x.id) < 0
          visited.push x.id
          g.addNode x.id, label: x.label
          for y in x.nodes
            recur y, visited
            g.addEdge null, y.id, x.id
      recur data, []

      svg = d3.select 'svg'
      svgGroup = svg.append 'g'
      layout = dagreD3.layout()
        .nodeSep 10
        .rankSep 10
        .rankDir 'RL'
      renderer = new dagreD3.Renderer()
      renderer.zoom false
      layout = renderer.layout(layout).run g, d3.select 'svg g'

      xCenterOffset = (svg.attr('width') - layout.graph().width) / 2
      svgGroup.attr('transform', "translate(#{xCenterOffset}, 20)")
      svg.attr('width', layout.graph().width + 40)
      svg.attr('height', layout.graph().height + 40)
