get = Em.get
set = Em.set

App.AccountRoutes = Em.Route.extend
    
  route: '/account'

  cancel: (router, event) ->
    router.get("applicationController.transaction").rollback()
    router.transitionTo("root.index")
  save: (router, event) ->
    router.get("applicationController.transaction").commit()
    router.transitionTo("books.index")
  
  index: Em.Route.extend
    route: '/'
    connectOutlets: (router, context) ->
      user = router.get "accountController.content"
      transaction = App.store.transaction()
      transaction.add user
      router.get("applicationController").set "transaction", transaction
      router.get("applicationController").connectOutlet "account"#, user

    unroutePath: (router, path) ->
      router.get("applicationController.transaction").rollback()
      @_super(router, path)