get = Em.get
set = Em.set

App.User = DS.Model.extend
  owner: DS.attr "string"
  emailBinding: "owner"
  firstName: DS.attr("string")
  lastName: DS.attr("string")
  bio: DS.attr("string")
  website: DS.attr("string")
  #isActive: DS.attr("boolean")
  createdOn: DS.attr("date")
  updatedOn: DS.attr("date")

  fullName: (->
    @get("firstName") + " " + @get("lastName")
  ).property "firstName", "lastName"

App.Book = DS.Model.extend
  title: DS.attr("string")
  description: DS.attr("string")
  url: DS.attr("string")
  type: DS.attr("string")
  isActive: DS.attr("boolean")
  createdOn: DS.attr("date")
  updatedOn: DS.attr("date")