$(document).ready ->
  $('#shopping-list').bootstrapTable()

  $('#name')
  .typeahead
      hint: true
      highlight: true
      minLength: 3
    ,
      name: 'types'
      displayKey: 'value'
      source: (q, cb) ->
        $.get '/api/typeLookup', query: q, (data) ->
          cb data.map (x) -> id: x[0], value: x[1]
  .on 'typeahead:autocompleted typeahead:selected', (event, data) ->
    $.get "/api/bom/#{data.id}", (data) ->
      g = new dagreD3.Digraph()

      recur = (x, visited) ->
        if !visited[x.id]?
          visited[x.id] = x
          g.addNode x.id, label: x.label
          for y in x.nodes
            recur y, visited
            g.addEdge null, y.id, x.id
      items = {}
      recur data, items

      svg = d3.select 'svg'
      svgGroup = svg.append 'g'
      layout = dagreD3.layout()
        .nodeSep 10
        .edgeSep 10
        .rankSep 10
        .rankDir 'RL'
      renderer = new dagreD3.Renderer()
      renderer.zoom false
      layout = renderer.layout(layout).run g, d3.select 'svg g'

      svgGroup.attr 'transform', "translate(0, 20)"
      svg.attr 'width', '100%'
      svg.attr 'height', layout.graph().height + 40

      $('#shopping-list').bootstrapTable 'load', (value for _, value of items when value.label isnt data.label and value.nodes.length is 0)
