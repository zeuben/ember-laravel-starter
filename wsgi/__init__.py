#import logging
from google.appengine.ext import webapp

import rest
import models
import base

MODELS = {
    'book': models.Book,
    'user': models.UserProfile
}

app = webapp.WSGIApplication(
    [
        ('/', base.IndexView),
        ('/user/me', base.UserView),
        ('/rest/.*', rest.Dispatcher),
    ],
    debug=True
)

rest.Dispatcher.base_url = '/rest'
rest.Dispatcher.output_content_types = [rest.JSON_CONTENT_TYPE]
rest.Dispatcher.add_models(MODELS)
rest.Dispatcher.authenticator = base.Authenticator()
rest.Dispatcher.authorizer = base.Authorizer()
