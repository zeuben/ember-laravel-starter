import re
import yaml
import random
import Cookie
import json
#import simplejson as json
import logging
from datetime import timedelta, datetime

import webapp2 as webapp
from google.appengine.ext.webapp import template
from google.appengine.api import users

import rest
import models


def get_current_user():
    user = users.get_current_user()
    return models.UserProfile.gql('WHERE owner = :1', user).get()


class Authenticator(rest.Authenticator):

    def authenticate(self, dispatcher):
        if not users.get_current_user():
            dispatcher.forbidden()
        elif not get_current_user():
            models.UserProfile().put()


class Authorizer(rest.Authorizer):

    def filter_read(self, dispatcher, models):
        models[:] = [model for model in models if model.readable]
        return models

    def filter_write(self, dispatcher, models, is_replace):
        models[:] = [model for model in models if model.writable]
        return models

    def can_read(self, dispatcher, model):
        if (not model.readable):
            dispatcher.forbidden()

    def can_write(self, dispatcher, model, is_replace):
        if hasattr(model, "set_defaults"):
            model.set_defaults()
        if (not model.writable):
            dispatcher.forbidden()

    def can_delete(self, dispatcher, model_type, model_key):
        model = model_type.gql('WHERE __key__ = :1', model_key).get()
        if (not model.writable):
            dispatcher.forbidden()
        elif hasattr(model, "rm"):
            model.rm()


class View(webapp.RequestHandler):

    def getCookie(self, key):
        cookies = self.request.cookies
        if key in cookies:
            return cookies.get(key)

    def setCookie(self, args):
        for key, value in args.iteritems():
            expires = (datetime.utcnow() + timedelta(days=30)).strftime('%a, %d %b %Y %H:%M:%S GMT')
            cookie = Cookie.SimpleCookie()
            cookie[key] = value
            #cookie[key]]['domain'] = '/'
            #cookie[key]['path'] = '/'
            cookie[key]['expires'] = expires
            cookie = str(re.compile('^Set-Cookie: ').sub('', cookie.output(), count=1))
            self.response.headers.add_header('Set-Cookie', cookie)

    def send(self, messages):
        for message in messages:
            server_id = random.randint(1, 100000)
            message.update({'id': server_id})
        res = {'events': [{'event': 'send', 'messages': messages}]}
        self.response.headers['Content-Type'] = 'application/json'
        self.response.out.write(json.dumps(res))

    def render(self, path, template_values={}):
        self.response.out.write(template.render('public/templates/{0}.html'.format(path), template_values))


class IndexView(View):

    def get(self):

        user = users.get_current_user()
        if user:
            self.redirect('/!/')

        else:
            self.render('login', {
                'login_url': users.create_login_url('/')
            })


class UserView(View):

    def get(self):
        user = get_current_user()
        if user:
            self.response.headers['Content-Type'] = 'application/json'
            return self.response.out.write(json.dumps({
                'key': unicode(user.key()),
                'logouturl': users.create_logout_url('/')
            }))
        return
