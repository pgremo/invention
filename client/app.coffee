requirejs.config
  paths:
    jquery: 'lib/jquery/dist/jquery.min'
    bootstrap: 'lib/bootstrap/dist/js/bootstrap.min'
    bootstrapvalidator: 'lib/bootstrapvalidator/dist/js/bootstrapValidator.min'
    d3: 'lib/d3/d3.min'
    dagre: 'lib/dagre/dist/dagre.core.min'
    dagreD3: 'lib/dagre-d3/dist/dagre-d3.core.min'
    graphlib: 'lib/graphlib/dist/graphlib.core.min'
    lodash: 'lib/lodash/dist/lodash.min'
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
    dagre:
      deps: ['graphlib']
    dagreD3:
      deps: ['d3', 'dagre']
      exports: 'dagreD3'
    graphlib:
      deps: ['lodash']
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
        .otherwise
          redirectTo: '/invention'
    ]
    .config ($httpProvider) ->
      $httpProvider.interceptors.push 'TokenInterceptor'
    .factory 'TokenInterceptor', ($q, $window) ->
        request:  (config) ->
          config.headers = config.headers or {}
          if $window.sessionStorage.token?
            config.headers.Authorization = "Bearer #{$window.sessionStorage.token}"
          config
        ,
        response:  (response) ->
          response or $q.when(response)
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

        g = new dagreD3.graphlib.Graph()
        g.setGraph(
            nodesep: 10
            edgesep: 10
            ranksep: 10
            rankdir: 'RL'
          )
          .setDefaultEdgeLabel(() -> {})

        recur = (x, visited) ->
          if !visited[x.id]?
            visited[x.id] = x
            g.setNode x.id, label: x.label, class: if not x.nodes? then 'leaf' else 'branch'
            if x.nodes?
              for y in x.nodes
                visited = recur y, visited
                g.setEdge y.id, x.id
          visited
        items = recur data, {}

        g.nodes().forEach (v) ->
          node = g.node v
          node.rx = node.ry = 5

        svg = d3.select 'svg'
        inner = svg.select 'g'

        renderer = new dagreD3.render()
        inner.call renderer, g

        svg.attr 'width', "#{g.graph().width}px"
        svg.attr 'height', "#{g.graph().height}px"

        $scope.items = (value for _, value of items when not value.nodes?)
    ]

  angular.element(document).ready () ->
    angular.bootstrap document, ['invention']
