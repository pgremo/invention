(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var archy;

archy = require('archy');

$(document).ready(function() {
  var getTypes;
  getTypes = function(q, cb) {
    return $.get("/api/typeLookup", {
      query: q
    }, function(data) {
      return cb(data.map(function(x) {
        return {
          id: x[0],
          value: x[1]
        };
      }));
    });
  };
  $('#name').typeahead({
    hint: true,
    highlight: true,
    minLength: 3
  }, {
    name: 'types',
    displayKey: 'value',
    source: getTypes
  });
  return $('#typeSearch').on('typeahead:selected', function(event, data) {
    return $.get("/api/bom/" + data.id, function(data) {
      return $('#result').html(archy(data));
    });
  });
});



},{"archy":2}],2:[function(require,module,exports){
module.exports = function archy (obj, prefix, opts) {
    if (prefix === undefined) prefix = '';
    if (!opts) opts = {};
    var chr = function (s) {
        var chars = {
            '│' : '|',
            '└' : '`',
            '├' : '+',
            '─' : '-',
            '┬' : '-'
        };
        return opts.unicode === false ? chars[s] : s;
    };
    
    if (typeof obj === 'string') obj = { label : obj };
    
    var nodes = obj.nodes || [];
    var lines = (obj.label || '').split('\n');
    var splitter = '\n' + prefix + (nodes.length ? chr('│') : ' ') + ' ';
    
    return prefix
        + lines.join(splitter) + '\n'
        + nodes.map(function (node, ix) {
            var last = ix === nodes.length - 1;
            var more = node.nodes && node.nodes.length;
            var prefix_ = prefix + (last ? ' ' : chr('│')) + ' ';
            
            return prefix
                + (last ? chr('└') : chr('├')) + chr('─')
                + (more ? chr('┬') : chr('─')) + ' '
                + archy(node, prefix_, opts).slice(prefix.length + 2)
            ;
        }).join('')
    ;
};

},{}]},{},[1])
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIi9Vc2Vycy9wbWdyZW1vL1Byb2plY3RzL2ludmVudGlvbi9ub2RlX21vZHVsZXMvZ3VscC1icm93c2VyaWZ5L25vZGVfbW9kdWxlcy9icm93c2VyaWZ5L25vZGVfbW9kdWxlcy9icm93c2VyLXBhY2svX3ByZWx1ZGUuanMiLCIvVXNlcnMvcG1ncmVtby9Qcm9qZWN0cy9pbnZlbnRpb24vY2xpZW50L2ludmVudGlvbi9pbnZlbnRpb24uY29mZmVlIiwiL1VzZXJzL3BtZ3JlbW8vUHJvamVjdHMvaW52ZW50aW9uL25vZGVfbW9kdWxlcy9hcmNoeS9pbmRleC5qcyJdLCJuYW1lcyI6W10sIm1hcHBpbmdzIjoiQUFBQTtBQ0FBLElBQUEsS0FBQTs7QUFBQSxLQUFBLEdBQVEsT0FBQSxDQUFRLE9BQVIsQ0FBUixDQUFBOztBQUFBLENBRUEsQ0FBRSxRQUFGLENBQVcsQ0FBQyxLQUFaLENBQWtCLFNBQUEsR0FBQTtBQUNoQixNQUFBLFFBQUE7QUFBQSxFQUFBLFFBQUEsR0FBVyxTQUFDLENBQUQsRUFBSSxFQUFKLEdBQUE7V0FDVCxDQUFDLENBQUMsR0FBRixDQUFNLGlCQUFOLEVBQXlCO0FBQUEsTUFBQSxLQUFBLEVBQU8sQ0FBUDtLQUF6QixFQUFtQyxTQUFDLElBQUQsR0FBQTthQUNqQyxFQUFBLENBQUcsSUFBSSxDQUFDLEdBQUwsQ0FBUyxTQUFDLENBQUQsR0FBQTtlQUFPO0FBQUEsVUFBQSxFQUFBLEVBQUksQ0FBRSxDQUFBLENBQUEsQ0FBTjtBQUFBLFVBQVUsS0FBQSxFQUFPLENBQUUsQ0FBQSxDQUFBLENBQW5CO1VBQVA7TUFBQSxDQUFULENBQUgsRUFEaUM7SUFBQSxDQUFuQyxFQURTO0VBQUEsQ0FBWCxDQUFBO0FBQUEsRUFJQSxDQUFBLENBQUUsT0FBRixDQUFVLENBQUMsU0FBWCxDQUNJO0FBQUEsSUFBQSxJQUFBLEVBQU0sSUFBTjtBQUFBLElBQ0EsU0FBQSxFQUFXLElBRFg7QUFBQSxJQUVBLFNBQUEsRUFBVyxDQUZYO0dBREosRUFLSTtBQUFBLElBQUEsSUFBQSxFQUFNLE9BQU47QUFBQSxJQUNBLFVBQUEsRUFBWSxPQURaO0FBQUEsSUFFQSxNQUFBLEVBQVEsUUFGUjtHQUxKLENBSkEsQ0FBQTtTQWFBLENBQUEsQ0FBRSxhQUFGLENBQWdCLENBQUMsRUFBakIsQ0FBb0Isb0JBQXBCLEVBQTBDLFNBQUMsS0FBRCxFQUFRLElBQVIsR0FBQTtXQUN4QyxDQUFDLENBQUMsR0FBRixDQUFPLFdBQUEsR0FBVyxJQUFJLENBQUMsRUFBdkIsRUFBNkIsU0FBQyxJQUFELEdBQUE7YUFDM0IsQ0FBQSxDQUFFLFNBQUYsQ0FBWSxDQUFDLElBQWIsQ0FBa0IsS0FBQSxDQUFNLElBQU4sQ0FBbEIsRUFEMkI7SUFBQSxDQUE3QixFQUR3QztFQUFBLENBQTFDLEVBZGdCO0FBQUEsQ0FBbEIsQ0FGQSxDQUFBOzs7OztBQ0FBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQTtBQUNBO0FBQ0E7QUFDQSIsImZpbGUiOiJnZW5lcmF0ZWQuanMiLCJzb3VyY2VSb290IjoiIiwic291cmNlc0NvbnRlbnQiOlsiKGZ1bmN0aW9uIGUodCxuLHIpe2Z1bmN0aW9uIHMobyx1KXtpZighbltvXSl7aWYoIXRbb10pe3ZhciBhPXR5cGVvZiByZXF1aXJlPT1cImZ1bmN0aW9uXCImJnJlcXVpcmU7aWYoIXUmJmEpcmV0dXJuIGEobywhMCk7aWYoaSlyZXR1cm4gaShvLCEwKTt0aHJvdyBuZXcgRXJyb3IoXCJDYW5ub3QgZmluZCBtb2R1bGUgJ1wiK28rXCInXCIpfXZhciBmPW5bb109e2V4cG9ydHM6e319O3Rbb11bMF0uY2FsbChmLmV4cG9ydHMsZnVuY3Rpb24oZSl7dmFyIG49dFtvXVsxXVtlXTtyZXR1cm4gcyhuP246ZSl9LGYsZi5leHBvcnRzLGUsdCxuLHIpfXJldHVybiBuW29dLmV4cG9ydHN9dmFyIGk9dHlwZW9mIHJlcXVpcmU9PVwiZnVuY3Rpb25cIiYmcmVxdWlyZTtmb3IodmFyIG89MDtvPHIubGVuZ3RoO28rKylzKHJbb10pO3JldHVybiBzfSkiLCJhcmNoeSA9IHJlcXVpcmUgJ2FyY2h5J1xuXG4kKGRvY3VtZW50KS5yZWFkeSAtPlxuICBnZXRUeXBlcyA9IChxLCBjYikgLT5cbiAgICAkLmdldCBcIi9hcGkvdHlwZUxvb2t1cFwiLCBxdWVyeTogcSwgKGRhdGEpIC0+XG4gICAgICBjYiBkYXRhLm1hcCAoeCkgLT4gaWQ6IHhbMF0sIHZhbHVlOiB4WzFdXG5cbiAgJCgnI25hbWUnKS50eXBlYWhlYWRcbiAgICAgIGhpbnQ6IHRydWUsXG4gICAgICBoaWdobGlnaHQ6IHRydWUsXG4gICAgICBtaW5MZW5ndGg6IDNcbiAgICAsXG4gICAgICBuYW1lOiAndHlwZXMnLFxuICAgICAgZGlzcGxheUtleTogJ3ZhbHVlJyxcbiAgICAgIHNvdXJjZTogZ2V0VHlwZXNcblxuICAkKCcjdHlwZVNlYXJjaCcpLm9uICd0eXBlYWhlYWQ6c2VsZWN0ZWQnLCAoZXZlbnQsIGRhdGEpIC0+XG4gICAgJC5nZXQgXCIvYXBpL2JvbS8je2RhdGEuaWR9XCIsIChkYXRhKSAtPlxuICAgICAgJCgnI3Jlc3VsdCcpLmh0bWwgYXJjaHkgZGF0YVxuIiwibW9kdWxlLmV4cG9ydHMgPSBmdW5jdGlvbiBhcmNoeSAob2JqLCBwcmVmaXgsIG9wdHMpIHtcbiAgICBpZiAocHJlZml4ID09PSB1bmRlZmluZWQpIHByZWZpeCA9ICcnO1xuICAgIGlmICghb3B0cykgb3B0cyA9IHt9O1xuICAgIHZhciBjaHIgPSBmdW5jdGlvbiAocykge1xuICAgICAgICB2YXIgY2hhcnMgPSB7XG4gICAgICAgICAgICAn4pSCJyA6ICd8JyxcbiAgICAgICAgICAgICfilJQnIDogJ2AnLFxuICAgICAgICAgICAgJ+KUnCcgOiAnKycsXG4gICAgICAgICAgICAn4pSAJyA6ICctJyxcbiAgICAgICAgICAgICfilKwnIDogJy0nXG4gICAgICAgIH07XG4gICAgICAgIHJldHVybiBvcHRzLnVuaWNvZGUgPT09IGZhbHNlID8gY2hhcnNbc10gOiBzO1xuICAgIH07XG4gICAgXG4gICAgaWYgKHR5cGVvZiBvYmogPT09ICdzdHJpbmcnKSBvYmogPSB7IGxhYmVsIDogb2JqIH07XG4gICAgXG4gICAgdmFyIG5vZGVzID0gb2JqLm5vZGVzIHx8IFtdO1xuICAgIHZhciBsaW5lcyA9IChvYmoubGFiZWwgfHwgJycpLnNwbGl0KCdcXG4nKTtcbiAgICB2YXIgc3BsaXR0ZXIgPSAnXFxuJyArIHByZWZpeCArIChub2Rlcy5sZW5ndGggPyBjaHIoJ+KUgicpIDogJyAnKSArICcgJztcbiAgICBcbiAgICByZXR1cm4gcHJlZml4XG4gICAgICAgICsgbGluZXMuam9pbihzcGxpdHRlcikgKyAnXFxuJ1xuICAgICAgICArIG5vZGVzLm1hcChmdW5jdGlvbiAobm9kZSwgaXgpIHtcbiAgICAgICAgICAgIHZhciBsYXN0ID0gaXggPT09IG5vZGVzLmxlbmd0aCAtIDE7XG4gICAgICAgICAgICB2YXIgbW9yZSA9IG5vZGUubm9kZXMgJiYgbm9kZS5ub2Rlcy5sZW5ndGg7XG4gICAgICAgICAgICB2YXIgcHJlZml4XyA9IHByZWZpeCArIChsYXN0ID8gJyAnIDogY2hyKCfilIInKSkgKyAnICc7XG4gICAgICAgICAgICBcbiAgICAgICAgICAgIHJldHVybiBwcmVmaXhcbiAgICAgICAgICAgICAgICArIChsYXN0ID8gY2hyKCfilJQnKSA6IGNocign4pScJykpICsgY2hyKCfilIAnKVxuICAgICAgICAgICAgICAgICsgKG1vcmUgPyBjaHIoJ+KUrCcpIDogY2hyKCfilIAnKSkgKyAnICdcbiAgICAgICAgICAgICAgICArIGFyY2h5KG5vZGUsIHByZWZpeF8sIG9wdHMpLnNsaWNlKHByZWZpeC5sZW5ndGggKyAyKVxuICAgICAgICAgICAgO1xuICAgICAgICB9KS5qb2luKCcnKVxuICAgIDtcbn07XG4iXX0=
