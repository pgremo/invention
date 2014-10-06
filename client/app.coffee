requirejs.config
  baseUrl: 'lib'
  paths:
    index: '../index'
    jquery: 'jquery/dist/jquery.min'
    bootstrap: 'bootstrap/dist/js/bootstrap.min'
    sammy: 'sammy/lib/min/sammy-0.7.6.min'
    typeahead: 'typeahead.js/dist/typeahead.bundle.min'
    'bootstrap-table': 'bootstrap-table/dist/bootstrap-table.min'
    d3: 'd3/d3.min'
    'dagre-d3': '../dagre-d3/dagre-d3'
  shim:
    bootstrap:
      deps: ['jquery']
    'bootstrap-table':
      deps: ['bootstrap']
    typeahead:
      deps: ['jquery']
    'dagre-d3':
      deps: ['d3']

requirejs ['index']
