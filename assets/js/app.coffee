require "jquery"
require "ember"
require "ember-data"
require "gae_adapter"

#bootstrap
modules = minispade.modules
for module of modules
    continue  unless modules.hasOwnProperty module
    minispade.require module if module.match /bootstrap/

window.App = Em.Application.create()

#templates
modules = minispade.modules
for module of modules
    continue  unless modules.hasOwnProperty module
    minispade.require module if module.match /\.html/

require "models"
require "views"
require "controllers"
require "store"
require "router"

App.initialize()