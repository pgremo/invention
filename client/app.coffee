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
      $locationProvider.html5Mode true
      $routeProvider
        .when '/invention',
          templateUrl: 'invention/view.html'
          controller: 'InventionController'
        .when '/profile',
          templateUrl: 'profile/view.html'
          controller: 'ProfileController'
        .otherwise
          redirectTo: () -> "/invention#{location.search}"
    ]
    .config ($httpProvider) ->
      $httpProvider.interceptors.push 'TokenInterceptor'
    .factory 'TokenInterceptor', ['$q', '$window', '$injector', '$location', ($q, $window, $injector, $location) ->
        request:  (config) ->
          config.headers = config.headers or {}
          if $window.sessionStorage.token?
            config.headers['x-access-token'] = $window.sessionStorage.token
          config
        ,
        responseError:  (response) ->
          if response.status is 401 and response.data.error and response.data.error is "invalid_token"
            deferred = $q.defer()
            $injector.get("$http").get('/api/auth/refresh').then ((loginResponse) ->
              if loginResponse.data
                $window.sessionStorage.token = loginResponse.data
                $injector.get("$http")(response.config).then ((response) ->
                  deferred.resolve response
                ), (response) ->
                  deferred.reject()
              else
                deferred.reject()
              return
            ), (response) ->
              deferred.reject()
              $location.path '/'
            deferred.promise
          else
            $q.reject response
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
    .controller 'SignInController', ['$scope', '$location', '$window', '$http', 'User', ($scope, $location, $window, $http, User) ->
      if $location.search().token?
        $window.sessionStorage.token = $location.search().token
        $location.search 'token', null

      if $window.sessionStorage.token?
        $scope.user = User.get()

      $scope.signOut = ->
        $http.get '/api/signout'
        delete $window.sessionStorage.token
        delete $scope.user
    ]
    .controller 'ProfileController', ['$location', '$scope', 'User', ($location, $scope, User) ->
      $scope.user = User.get()

      $scope.updateProfile = () ->
        if not $scope.registration.$valid then return
        User.save $scope.user, () -> $location.path '/invention'
    ]
    .controller 'InventionController', ['$scope', '$http', 'BoM', ($scope, $http, BoM) ->
      $scope.name = ''
      $scope.ml = 0
      $scope.quantity = 1
      $scope.type = {}

      $scope.refreshTypes = (query) ->
        if query.length < 3 then return
        $http.get '/api/typeLookup', params: {query: query}
          .then (result) ->
            $scope.types = result.data?.map (x) -> id: x[0], value: x[1]

      $scope.$watch 'type.selected', (newValue) ->
        if newValue?
          BoM.get id: newValue.id, ml: $scope.ml, quantity: $scope.quantity, (result) ->
            $scope.bom = result

      $scope.$watch 'ml', (newValue, oldValue) ->
        if newValue? and newValue isnt oldValue and $scope.type.selected?
          BoM.get id: $scope.type.selected.id, ml: newValue, quantity: $scope.quantity, (result) ->
            $scope.bom = result

      $scope.$watch 'quantity', (newValue, oldValue) ->
        if newValue? and newValue isnt oldValue and $scope.type.selected?
          BoM.get id: $scope.type.selected.id, ml: $scope.ml, quantity: newValue, (result) ->
            $scope.bom = result

      unless Array::find
        Array::find = (predicate) ->
          for x in this
            if predicate x
              return x
          return undefined;

      flatten = (x, visited) ->
        if not visited.find((i) -> i.id is x.id)?
          visited.push x
          if x.nodes?
            for y in x.nodes
              visited = flatten y, visited
        visited

      $scope.$watch 'bom', (data) ->
        $scope.items = flatten data, [] if data?

      $scope.$watch 'items', (items) ->
        if not items? then return

        g = new dagreD3.graphlib.Graph().setGraph(
            nodesep: 10
            edgesep: 10
            ranksep: 10
            rankdir: 'RL'
          )
          .setDefaultEdgeLabel () -> {}

        for x in items
          g.setNode x.id, label: x.label, class: if not x.nodes? then 'leaf' else 'branch'

        for x in items
          if x.nodes?
            for y in x.nodes
              g.setEdge y.id, x.id

        for v in g.nodes()
          node = g.node v
          node.rx = node.ry = 5

        svg = d3.select 'svg'
        inner = svg.select 'g'

        renderer = new dagreD3.render()
        renderer inner, g

        inner.attr 'transform', 'translate(20, 20)'
        svg.attr 'width', "#{g.graph().width + 40}px"
        svg.attr 'height', "#{g.graph().height + 40}px"

      $scope.$watch 'items', (items) ->
        if not items? then return
        $scope.itemToBuy = (value for _, value of items when not value.nodes?)
    ]

  angular.element(document).ready () ->
    angular.bootstrap document, ['invention']
