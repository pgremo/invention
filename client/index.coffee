(($) ->
  app = $.sammy('#main', ->
    @debug = true

    @get '#/invention/:id?', -> @partial '/invention/index.html'

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
  )
  $ -> app.run()
) jQuery
