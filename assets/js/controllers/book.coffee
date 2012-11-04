App.BooksController = Em.ArrayController.extend

  isLoaded: (->
    if @get("length") isnt 0
      @filterProperty('isLoaded', true).get('length')
    else
      true
  ).property '@each.isLoaded'

  deleteChecked: ->

    store = App.store
    items = @filterProperty('isChecked', true)
    length = items.get("length")
    note = "Delete "
    note += (length + " ") if length > 1
    note += "book"
    note += "s" if length > 1 
    note += " ?"
    if confirm(note)
      items.forEach (item) ->
        store.deleteRecord(item)
      store.commit()

  allAreChecked: ( (key, value) ->
    
    if value isnt undefined
      @setEach 'isChecked', value
      value
    else
      @get('length') && @everyProperty('isChecked', true)

  ).property('@each.isChecked')

  isEmpty: (->
    @filterProperty('isChecked', true).get("length") is 0 or undefined
  ).property "@each.isChecked"

App.BookController = Em.Controller.extend
  activeStates: [
    true
    false
  ]