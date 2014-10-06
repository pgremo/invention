define ['jquery', 'bootstrap', 'sammy', 'typeahead', 'bootstrap-table', 'd3', 'dagre-d3'], ($, bootstrap, sammy, typeahead, bootstrapTable, d3, dagreD3) ->
  app = sammy '#main', ->
    @debug = true

    @get '#/invention/:id?', ->
      @partial '/invention/index.html'
      .then (content) ->
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
                g.addNode x.id, label: x.label, nodeClass: if x.nodes.length is 0 then 'leaf' else 'branch'
                for y in x.nodes
                  recur y, visited
                  g.addEdge null, y.id, x.id
              visited
            items = recur data, {}

            svg = d3.select 'svg'
            svgGroup = svg.append 'g'
            layout = dagreD3.layout()
            .nodeSep 10
            .edgeSep 10
            .rankSep 10
            .rankDir 'RL'
            renderer = new dagreD3.Renderer()

            oldDrawNodes = renderer.drawNodes();
            renderer.drawNodes (graph, root) ->
              svgNodes = oldDrawNodes graph, root
              svgNodes.each (u) -> d3.select(this).classed(graph.node(u).nodeClass, true)
              svgNodes;

            renderer.zoom false
            layout = renderer.layout(layout).run g, d3.select 'svg g'

            svgGroup.attr 'transform', "translate(0, 20)"
            svg.attr 'width', layout.graph().width + 20
            svg.attr 'height', layout.graph().height + 40

            $('#shopping-list').bootstrapTable 'load', (value for _, value of items when value.label isnt data.label and value.nodes.length is 0)
        content

    @get '#/register', -> @partial '/register/index.html'

    @post '#/register', ->
      form_fields = @params
      @log form_fields
      @redirect '#/invention/'

    @get '#/signIn', -> @partial '/signIn/index.html'

    @post '#/signIn', ->
      form_fields = @params
      @log form_fields
      @redirect '#/invention/'

    @get '', -> app.runRoute 'get', '#/invention/'
  $ -> app.run()
