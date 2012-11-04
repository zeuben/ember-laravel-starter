get = Em.get
set = Em.set

App.AccountController = Em.Controller.extend
  init: ->
    # sideload user
    that = @
    Em.$.ajax
      url: '/user/me'
      type: "GET"
      contentType: "application/json"
      success: (json) ->
        user = App.store.find App.User, json.key
        that.setProperties
          content: user
          logouturl: json.logouturl