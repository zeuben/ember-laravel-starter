require("routes/book")
require("routes/account")

App.ApplicationRoutes = Em.Route.extend
  index: Em.Route.extend
    route: '/'
    redirectsTo: 'books.index'

  editAccount: Em.Route.transitionTo "account.index"

  account: App.AccountRoutes.extend()
  books: App.BookRoutes.extend()
