# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $('.twitter_submit').click ->
    payload = twitter_username: $('#twitter_username').val()
    $('.sentence-container').hide 0
    $('.error-container').hide 0
    # Instantiate baffle
    b = baffle('.sentence-container')
    be = baffle('.error-container')
    b.text(->
      'Generating... (May take a minute or two)'
    ).reveal 3000
    $('.sentence-container').show 0

    $.post '/markov/fetch_twitter_chain.json', payload, (data) ->
      b.stop()
      if data.error
        $('.sentence-container').hide 0
        be.text(->
          data.error
        ).reveal 250
        $('.error-container').show 0
      else
        $('.error-container').hide 0
        b.text(->
          data.sentence
        ).reveal 250
        $('.sentence-container').show 0
      return
    return
