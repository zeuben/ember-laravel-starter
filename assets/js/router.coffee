require("routes/application")

App.Router = Em.Router.extend
  enableLogging: true
  location: "hash"
  root: App.ApplicationRoutes.extend()
