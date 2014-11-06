requirejs.config
  paths:
    jquery: 'lib/jquery/dist/jquery.min'
    bootstrap: 'lib/bootstrap/dist/js/bootstrap.min'
    bootstrapvalidator: 'lib/bootstrapvalidator/dist/js/bootstrapValidator.min'
    d3: 'lib/d3/d3.min'
    dagreD3: 'dagre-d3/dagre-d3'
    angular: 'lib/angular/angular.min'
    angularSanitize: 'lib/angular-sanitize/angular-sanitize.min'
    angularRoute: 'lib/angular-route/angular-route.min'
    angularResource: 'lib/angular-resource/angular-resource.min'
    angularUISelect: 'lib/angular-ui-select/dist/select.min'
    angularSmartTable: 'lib/angular-smart-table/dist/smart-table.min'
    angularMessages: 'lib/angular-messages/angular-messages.min'
  shim:
    bootstrap:
      deps: ['jquery']
    bootstrapvalidator:
      deps: ['jquery']
    dagreD3:
      deps: ['d3']
    angular:
      deps: ['jquery']
      exports: 'angular'
    angularSanitize:
      deps: ['angular']
    angularResource:
      deps: ['angular']
    angularRoute:
      deps: ['angular']
    angularMessages:
      deps: ['angular']
    angularSmartTable:
      deps: ['angular']
    angularUISelect:
      deps: ['angular', 'bootstrap']

require ['angular', 'dagreD3', 'd3', 'angularResource', 'angularRoute', 'angularSanitize', 'angularUISelect', 'angularSmartTable', 'angularMessages'], (angular, dagreD3, d3) ->
  app = angular.module 'invention', ['ngResource', 'ngRoute', 'ngSanitize', 'ui.select', 'smart-table', 'ngMessages']
    .config ['$routeProvider', '$locationProvider', ($routeProvider, $locationProvider) ->
      $locationProvider.html5Mode false
      $routeProvider
        .when '/invention',
          templateUrl: 'invention/view.html'
          controller: 'InventionController'
        .when '/register',
          templateUrl: 'register/view.html'
          controller: 'RegistrationController'
        .when '/signon',
          redirectTo: '/api/auth/eveonline'
        .otherwise
          redirectTo: '/invention'
    ]
    .factory 'BoM', ['$resource', ($resource) ->
      $resource '/api/bom/:id', {}
    ]
    .factory 'User', ['$resource', ($resource) ->
      $resource '/api/users', {}
    ]
    .directive 'match', ->
      require: 'ngModel'
      restrict: 'A'
      scope:
        match: '='
      link: ($scope, elem, attrs, $controller) ->
        $scope.$watch 'match', -> $controller.$validate()
        $controller.$validators.match = (model, view) -> $scope.match in [model, view]
    .directive 'remote', ['$q', '$http', ($q, $http) ->
      require: 'ngModel'
      restrict: 'A'
      scope:
        validateParams: '=?'
        revalidateOn: '=?'
      link: ($scope, elem, attrs, $controller) ->
        if attrs.revalidateOn then $scope.$watch 'revalidateOn', -> $controller.$validate()
        $controller.$asyncValidators.remote = (model, view) ->
          data = {}
          data[attrs.name] = model or view
          for key, value of $scope.validateParams
            data[key] = value
          deferred = $q.defer()
          $http.post attrs.remote, data
            .then (response) ->
              if response.data.isValid then deferred.resolve() else deferred.reject()
            .catch () ->
              deferred.reject()
          deferred.promise
    ]
    .controller 'RegistrationController', ['$location', '$scope', 'User', ($location, $scope, User) ->
      $scope.user = {}

      $scope.registerUser = () ->
        if not $scope.registration.$valid then return
        User.save $scope.user,
          (() ->
            $location.path '/invention'),
          ((response) ->
            if response.data.error.error is 'E_VALIDATION'
              for key, value of response.data.error.invalidAttributes
                for item in value
                  $scope.registration[key].$dirty = true
                  $scope.registration[key].$setValidity item.rule, false)
    ]
    .controller 'InventionController', ['$scope', '$http', 'BoM', ($scope, $http, BoM) ->
      $scope.name = ''
      $scope.me = 1.0

      $scope.type = {}
      $scope.refreshTypes = (query) ->
        if query.length < 3 then return
        $http.get '/api/typeLookup', params: {query: query}
          .then (result) ->
            $scope.types = result.data?.map (x) -> id: x[0], value: x[1]

      $scope.$watch 'type.selected', (newValue) ->
        if newValue?
          BoM.get id: newValue.id, me: $scope.me, (result) ->
            $scope.bom = result

      $scope.$watch 'me', (newValue, oldValue) ->
        if newValue? and newValue isnt oldValue and $scope.type.selected?
          BoM.get id: $scope.type.selected.id, me: newValue, (result) ->
            $scope.bom = result

      $scope.$watch 'bom', (data) ->
        if not data? then return

        g = new dagreD3.Digraph()

        recur = (x, visited) ->
          if !visited[x.id]?
            visited[x.id] = x
            g.addNode x.id, label: x.label, nodeClass: if not x.nodes? then 'leaf' else 'branch'
            if x.nodes?
              for y in x.nodes
                visited = recur y, visited
                g.addEdge null, y.id, x.id
          visited
        items = recur data, {}

        renderer = new dagreD3.Renderer()

        oldDrawNodes = renderer.drawNodes()
        renderer.drawNodes (graph, root) ->
          svgNodes = oldDrawNodes graph, root
          svgNodes.each (u) -> d3.select(this).classed graph.node(u).nodeClass, true
          svgNodes

        svg = d3.select 'svg'
        svgGroup = svg.append 'g'
        layout = dagreD3.layout()
          .nodeSep 10
          .edgeSep 10
          .rankSep 10
          .rankDir 'RL'
        layout = renderer.zoom(false).layout(layout).run g, d3.select 'svg g'

        svgGroup.attr 'transform', "translate(0, 20)"
        svg.attr 'width', layout.graph().width + 20
        svg.attr 'height', layout.graph().height + 40

        $scope.items = (value for _, value of items when not value.nodes?)
    ]

  angular.element(document).ready () ->
    angular.bootstrap document, ['invention']
