App.BookRoutes = Em.Route.extend

  route: "/books"

  createBook: Em.Route.transitionTo "create"
  editBook: Em.Route.transitionTo "edit"
  back: Em.Route.transitionTo "books.index"

  cancel: (router, event) ->
    router.get("applicationController.transaction").rollback()
    router.transitionTo "index"
  save: (router, event) ->
    router.get("applicationController.transaction").commit()
    router.transitionTo "index"

  index: Em.Route.extend
    route: "/"
    connectOutlets: (router, context) ->
      books = App.store.find App.Book
      router.get("applicationController").connectOutlet "books", books

  create: Em.Route.extend
    route: "/new"
    connectOutlets: (router) ->
      transaction = App.store.transaction()
      book = transaction.createRecord(App.Book)
      applicationController = router.get("applicationController")
      applicationController.set "transaction", transaction
      applicationController.connectOutlet "book", book

    unroutePath: (router, path) ->
      router.get("applicationController.transaction").rollback()
      @_super(router, path)


  edit: Em.Route.extend

    route: "/:book_id"
    connectOutlets: (router, book) ->

      transaction = App.store.transaction()
      transaction.add book
      applicationController = router.get("applicationController")
      applicationController.set "transaction", transaction
      applicationController.connectOutlet "book", book

    unroutePath: (router, path) ->
      router.get("applicationController.transaction").rollback()
      @_super(router, path)

