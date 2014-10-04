(($) ->
  app = $.sammy('#main', ->
    @debug = true

    @get '#/invention/:id?', -> @partial '/invention/index.html'

    @get '#/register', -> @partial '/register/index.html'

    @get '#/login', -> @partial '/login/index.html'

    @get '', -> app.runRoute 'get', '#/invention/'
  )
  $ -> app.run()
) jQuery
