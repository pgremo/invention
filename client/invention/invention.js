(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
$(document).ready(function() {
  $('#shopping-list').bootstrapTable();
  return $('#name').typeahead({
    hint: true,
    highlight: true,
    minLength: 3
  }, {
    name: 'types',
    displayKey: 'value',
    source: function(q, cb) {
      return $.get('/api/typeLookup', {
        query: q
      }, function(data) {
        return cb(data.map(function(x) {
          return {
            id: x[0],
            value: x[1]
          };
        }));
      });
    }
  }).on('typeahead:autocompleted typeahead:selected', function(event, data) {
    return $.get("/api/bom/" + data.id, function(data) {
      var g, items, layout, recur, renderer, svg, svgGroup, value, xCenterOffset, _;
      g = new dagreD3.Digraph();
      recur = function(x, visited) {
        var y, _i, _len, _ref, _results;
        if (visited[x.id] == null) {
          visited[x.id] = x;
          g.addNode(x.id, {
            label: x.label
          });
          _ref = x.nodes;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            y = _ref[_i];
            recur(y, visited);
            _results.push(g.addEdge(null, y.id, x.id));
          }
          return _results;
        }
      };
      items = {};
      recur(data, items);
      svg = d3.select('svg');
      svgGroup = svg.append('g');
      layout = dagreD3.layout().nodeSep(10).edgeSep(10).rankSep(10).rankDir('RL');
      renderer = new dagreD3.Renderer();
      renderer.zoom(false);
      layout = renderer.layout(layout).run(g, d3.select('svg g'));
      xCenterOffset = (svg.attr('width') - layout.graph().width) / 2;
      svgGroup.attr('transform', "translate(" + xCenterOffset + ", 20)");
      svg.attr('width', '100%');
      svg.attr('height', layout.graph().height + 40);
      return $('#shopping-list').bootstrapTable('load', (function() {
        var _results;
        _results = [];
        for (_ in items) {
          value = items[_];
          if (value.label !== data.label && value.nodes.length === 0) {
            _results.push(value);
          }
        }
        return _results;
      })());
    });
  });
});



},{}]},{},[1])
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi9Vc2Vycy9wbWdyZW1vL1Byb2plY3RzL2ludmVudGlvbi9ub2RlX21vZHVsZXMvZ3VscC1icm93c2VyaWZ5L25vZGVfbW9kdWxlcy9icm93c2VyaWZ5L25vZGVfbW9kdWxlcy9icm93c2VyLXBhY2svX3ByZWx1ZGUuanMiLCIvVXNlcnMvcG1ncmVtby9Qcm9qZWN0cy9pbnZlbnRpb24vY2xpZW50L2ludmVudGlvbi9pbnZlbnRpb24uY29mZmVlIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiJBQUFBO0FDQUEsQ0FBQSxDQUFFLFFBQUYsQ0FBVyxDQUFDLEtBQVosQ0FBa0IsU0FBQSxHQUFBO0FBQ2hCLEVBQUEsQ0FBQSxDQUFFLGdCQUFGLENBQW1CLENBQUMsY0FBcEIsQ0FBQSxDQUFBLENBQUE7U0FFQSxDQUFBLENBQUUsT0FBRixDQUNBLENBQUMsU0FERCxDQUVJO0FBQUEsSUFBQSxJQUFBLEVBQU0sSUFBTjtBQUFBLElBQ0EsU0FBQSxFQUFXLElBRFg7QUFBQSxJQUVBLFNBQUEsRUFBVyxDQUZYO0dBRkosRUFNSTtBQUFBLElBQUEsSUFBQSxFQUFNLE9BQU47QUFBQSxJQUNBLFVBQUEsRUFBWSxPQURaO0FBQUEsSUFFQSxNQUFBLEVBQVEsU0FBQyxDQUFELEVBQUksRUFBSixHQUFBO2FBQ04sQ0FBQyxDQUFDLEdBQUYsQ0FBTSxpQkFBTixFQUF5QjtBQUFBLFFBQUEsS0FBQSxFQUFPLENBQVA7T0FBekIsRUFBbUMsU0FBQyxJQUFELEdBQUE7ZUFDakMsRUFBQSxDQUFHLElBQUksQ0FBQyxHQUFMLENBQVMsU0FBQyxDQUFELEdBQUE7aUJBQU87QUFBQSxZQUFBLEVBQUEsRUFBSSxDQUFFLENBQUEsQ0FBQSxDQUFOO0FBQUEsWUFBVSxLQUFBLEVBQU8sQ0FBRSxDQUFBLENBQUEsQ0FBbkI7WUFBUDtRQUFBLENBQVQsQ0FBSCxFQURpQztNQUFBLENBQW5DLEVBRE07SUFBQSxDQUZSO0dBTkosQ0FXQSxDQUFDLEVBWEQsQ0FXSSw0Q0FYSixFQVdrRCxTQUFD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b3VyY2VSb290IjoiIiwic291cmNlc0NvbnRlbnQiOlsiKGZ1bmN0aW9uIGUodCxuLHIpe2Z1bmN0aW9uIHMobyx1KXtpZighbltvXSl7aWYoIXRbb10pe3ZhciBhPXR5cGVvZiByZXF1aXJlPT1cImZ1bmN0aW9uXCImJnJlcXVpcmU7aWYoIXUmJmEpcmV0dXJuIGEobywhMCk7aWYoaSlyZXR1cm4gaShvLCEwKTt0aHJvdyBuZXcgRXJyb3IoXCJDYW5ub3QgZmluZCBtb2R1bGUgJ1wiK28rXCInXCIpfXZhciBmPW5bb109e2V4cG9ydHM6e319O3Rbb11bMF0uY2FsbChmLmV4cG9ydHMsZnVuY3Rpb24oZSl7dmFyIG49dFtvXVsxXVtlXTtyZXR1cm4gcyhuP246ZSl9LGYsZi5leHBvcnRzLGUsdCxuLHIpfXJldHVybiBuW29dLmV4cG9ydHN9dmFyIGk9dHlwZW9mIHJlcXVpcmU9PVwiZnVuY3Rpb25cIiYmcmVxdWlyZTtmb3IodmFyIG89MDtvPHIubGVuZ3RoO28rKylzKHJbb10pO3JldHVybiBzfSkiLCIkKGRvY3VtZW50KS5yZWFkeSAtPlxuICAkKCcjc2hvcHBpbmctbGlzdCcpLmJvb3RzdHJhcFRhYmxlKClcblxuICAkKCcjbmFtZScpXG4gIC50eXBlYWhlYWRcbiAgICAgIGhpbnQ6IHRydWVcbiAgICAgIGhpZ2hsaWdodDogdHJ1ZVxuICAgICAgbWluTGVuZ3RoOiAzXG4gICAgLFxuICAgICAgbmFtZTogJ3R5cGVzJ1xuICAgICAgZGlzcGxheUtleTogJ3ZhbHVlJ1xuICAgICAgc291cmNlOiAocSwgY2IpIC0+XG4gICAgICAgICQuZ2V0ICcvYXBpL3R5cGVMb29rdXAnLCBxdWVyeTogcSwgKGRhdGEpIC0+XG4gICAgICAgICAgY2IgZGF0YS5tYXAgKHgpIC0+IGlkOiB4WzBdLCB2YWx1ZTogeFsxXVxuICAub24gJ3R5cGVhaGVhZDphdXRvY29tcGxldGVkIHR5cGVhaGVhZDpzZWxlY3RlZCcsIChldmVudCwgZGF0YSkgLT5cbiAgICAkLmdldCBcIi9hcGkvYm9tLyN7ZGF0YS5pZH1cIiwgKGRhdGEpIC0+XG4gICAgICBnID0gbmV3IGRhZ3JlRDMuRGlncmFwaCgpXG5cbiAgICAgIHJlY3VyID0gKHgsIHZpc2l0ZWQpIC0+XG4gICAgICAgIGlmICF2aXNpdGVkW3guaWRdP1xuICAgICAgICAgIHZpc2l0ZWRbeC5pZF0gPSB4XG4gICAgICAgICAgZy5hZGROb2RlIHguaWQsIGxhYmVsOiB4LmxhYmVsXG4gICAgICAgICAgZm9yIHkgaW4geC5ub2Rlc1xuICAgICAgICAgICAgcmVjdXIgeSwgdmlzaXRlZFxuICAgICAgICAgICAgZy5hZGRFZGdlIG51bGwsIHkuaWQsIHguaWRcbiAgICAgIGl0ZW1zID0ge31cbiAgICAgIHJlY3VyIGRhdGEsIGl0ZW1zXG5cbiAgICAgIHN2ZyA9IGQzLnNlbGVjdCAnc3ZnJ1xuICAgICAgc3ZnR3JvdXAgPSBzdmcuYXBwZW5kICdnJ1xuICAgICAgbGF5b3V0ID0gZGFncmVEMy5sYXlvdXQoKVxuICAgICAgICAubm9kZVNlcCAxMFxuICAgICAgICAuZWRnZVNlcCAxMFxuICAgICAgICAucmFua1NlcCAxMFxuICAgICAgICAucmFua0RpciAnUkwnXG4gICAgICByZW5kZXJlciA9IG5ldyBkYWdyZUQzLlJlbmRlcmVyKClcbiAgICAgIHJlbmRlcmVyLnpvb20gZmFsc2VcbiAgICAgIGxheW91dCA9IHJlbmRlcmVyLmxheW91dChsYXlvdXQpLnJ1biBnLCBkMy5zZWxlY3QgJ3N2ZyBnJ1xuXG4gICAgICB4Q2VudGVyT2Zmc2V0ID0gKHN2Zy5hdHRyKCd3aWR0aCcpIC0gbGF5b3V0LmdyYXBoKCkud2lkdGgpIC8gMlxuICAgICAgc3ZnR3JvdXAuYXR0ciAndHJhbnNmb3JtJywgXCJ0cmFuc2xhdGUoI3t4Q2VudGVyT2Zmc2V0fSwgMjApXCJcbiAgICAgIHN2Zy5hdHRyICd3aWR0aCcsICcxMDAlJ1xuICAgICAgc3ZnLmF0dHIgJ2hlaWdodCcsIGxheW91dC5ncmFwaCgpLmhlaWdodCArIDQwXG5cbiAgICAgICQoJyNzaG9wcGluZy1saXN0JykuYm9vdHN0cmFwVGFibGUgJ2xvYWQnLCAodmFsdWUgZm9yIF8sIHZhbHVlIG9mIGl0ZW1zIHdoZW4gdmFsdWUubGFiZWwgaXNudCBkYXRhLmxhYmVsIGFuZCB2YWx1ZS5ub2Rlcy5sZW5ndGggaXMgMClcbiJdfQ==
