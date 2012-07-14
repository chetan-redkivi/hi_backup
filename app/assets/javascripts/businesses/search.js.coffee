# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

window.initialize_business_search = (url) ->
  $('#twitter_search').slider {
    range: true
    min: 0
    max: 1000
    step: 50
    values: [50,900]
    stop: -> fetch_results(url)
  }
  $('#facebook_search').slider {
    range: true
    min: 0
    max: 1000
    step: 50
    values: [50,900]
    stop: -> fetch_results(url)
  }

  fetch_results(url)

fetch_results = (url) ->
    $.ajax({
      url: url
      type: 'POST'
      data: {
        twitter: get_slider_range($('#twitter_search'))
        facebook: get_slider_range($('#facebook_search'))
      }
      success: (data) ->
        $('#search_results').html('')
        res = data['users'].map( (u) ->
          '<div>'+u['email']+'</div>'
        )
        $('#search_results').append(res.join(""))
    })

get_slider_range = (sel) ->
  ""+sel.slider('values', 0)+".."+sel.slider('values', 1)
