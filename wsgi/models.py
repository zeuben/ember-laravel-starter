#import logging
from google.appengine.ext import db
from google.appengine.api import users


class Model(db.Model):
    owner = db.UserProperty(auto_current_user=True)

    @property
    def readable(self):
        return self.owner == users.get_current_user()

    @property
    def writable(self):
        return self.readable


class Book(Model):
    title = db.StringProperty()
    description = db.TextProperty()
    url = db.LinkProperty()
    type = db.StringProperty()
    is_active = db.BooleanProperty()
    created_on = db.DateTimeProperty(auto_now=True)
    updated_on = db.DateTimeProperty(auto_now_add=True)

class UserProfile(Model):
    first_name = db.StringProperty()
    last_name = db.StringProperty()
    bio = db.TextProperty()
    website = db.LinkProperty()
    #isActive = db.BooleanProperty()
    created_on = db.DateTimeProperty(auto_now=True)
    updated_on = db.DateTimeProperty(auto_now_add=True)