archy = require 'archy'

$(document).ready ->
  getTypes = (q, cb) ->
    $.get "/api/typeLookup", query: q, (data) ->
      cb data.map (x) -> id: x[0], value: x[1]

  $('#name').typeahead
      hint: true,
      highlight: true,
      minLength: 3
    ,
      name: 'types',
      displayKey: 'value',
      source: getTypes

  $('#typeSearch').on 'typeahead:selected', (event, data) ->
    $.get "/api/bom/#{data.id}", (data) ->
      $('#result').html archy data
