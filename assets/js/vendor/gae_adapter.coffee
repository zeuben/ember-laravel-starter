DS = window.DS
Em = window.Em

get = Em.get
set = Em.set

DS.Model.reopen
  primaryKey: "key"

DS.attr.transforms.array =
  from: (serialized) ->
    if serialized is undefined or null
      []
    else
      array = get serialized, "item"
      switch Em.isArray(array)
        when true
          array
        else
          Em.A([array])
  to: (deserialized) ->
    switch Em.isArray(deserialized)
      when true
        array = deserialized
      else
        array = []
    item: array

DS.attr.transforms.boolean =
  from: (serialized) ->
    switch serialized
      when 'true'
        true
      when 'false'
        false
      else 
        null
  to: (deserialized) ->
    switch deserialized
      when true
        'true'
      when false 
        'false'
      else
        null

DS.GAEAdapter = DS.RESTAdapter.extend

  #set associations to keys
  setAssociationsToKeys: (type, model) ->
    that = @
    root = @rootForType type
    json = model.toJSON(associations: true)
    associations = get(type, "associationsByName")
    associations.forEach (key, meta) ->
      if meta.kind is "belongsTo"
        keyId = meta.options.key or get(model, "namingConvention").foreignKey(key)
        value = json[keyId]
        json[key] = value
        delete json[keyId]
      else if meta.kind is "hasMany"
        key = meta.options.key or get(model, "namingConvention").keyToJSONKey(key)
        value = json[key]
        json[key] = 
          item: value
    data = {}
    data["#{root}"] = json
    JSON.stringify data

  
  # set associations from keys
  sideloadAssociations: (type, json) ->
    that = @
    root = @rootForType type
    meta = undefined
    value = undefined
    get(type, "associationsByName").forEach (key, meta) ->
      meta = type.metaForProperty(key)
      if meta.kind is "belongsTo"
        keyId = meta.options.key or type::get("namingConvention").foreignKey(key)
        value = json[key]
        json[keyId] = (
          if meta.options.embedded
          then that.sideloadAssociations(meta.type, value)
          else value
        )
        delete json[key]
      else if meta.kind is "hasMany"
        key = meta.options.key or type::get("namingConvention").keyToJSONKey(key)
        json[key] = json[key]["item"]?.map (item) ->
          if meta.options.embedded else item

    json

  ajax: (url, type, hash) ->
    hash.url = "/rest/#{url}"
    hash.type = type
    hash.dataType = "json"
    hash.contentType = "application/json"

    #return full data
    if hash.type in [
      'POST'
      'PUT'
    ]
      hash.url += "?type=full"

    jQuery.ajax hash

  #backend doesn't pluralize names for lists
  pluralize: (name) ->
    name

  createRecord: (store, type, model) ->
    that = @
    root = @rootForType type
    data = @setAssociationsToKeys type, model
    @ajax root, "POST",
      data: data
      success: (json) ->
        json = that.sideloadAssociations type, json[root]
        store.didCreateRecord model, json 
      error: (error) ->

  updateRecord: (store, type, model) ->
    that = @
    id = get model, "id"
    root = @rootForType type
    data = @setAssociationsToKeys type, model        
    @ajax "#{root}/#{id}", "PUT",
      data: data
      success: (json) ->
        json = that.sideloadAssociations type, json[root]
        store.didUpdateRecord model, json
      error: (error) ->

  deleteRecord: (store, type, model) ->
    that = @
    id = get(model, "id");
    root = @rootForType(type);

    @ajax "#{root}/#{id}", "DELETE",
      success: (json) ->
        store.didDeleteRecord model
      error: (error) ->

  find: (store, type, id) ->
    that = @
    root = @rootForType type

    @ajax "#{root}/#{id}", "GET",
      success: (json) ->
        json = json[root] ? {}
        if json
          json = that.sideloadAssociations type, json 
        store.load type, json

  findMany: ->
    @find.apply this, arguments

  findAll: (store, type) ->
    that = @
    root = @rootForType type

    @ajax root, "GET",
      success: (json) ->
        json = json["list"][root] ? []
        if json
          if json instanceof Array
            json.forEach (item, i, collection) ->
              collection[i] = that.sideloadAssociations type, item
          else
            json = [that.sideloadAssociations type, json]
        store.loadMany type, json

  findQuery: (store, type, query, modelArray) ->
    that = @
    root = @rootForType type
    @ajax root, "GET",
      data: query
      success: (json) ->
        json = json["list"][root] ? []
        if json
          if json instanceof Array
            json.forEach (item, i, collection) ->
              collection[i] = that.sideloadAssociations type, item
          else
            json = [that.sideloadAssociations type, json]
        modelArray.load json

