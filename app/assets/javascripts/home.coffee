# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $('.twitter_submit').click ->
    payload = twitter_username: $('#twitter_username').val()
    $.post '/markov/fetch_twitter_chain.json', payload, (data) ->
      if data.error
        $('.error-container span').text data.error
        $('.error-container').show 100
        $('.sentence-container').hide 100
      else
        $('.sentence-container span').text data.sentence
        $('.sentence-container').show 100
        $('.error-container').hide 100
      return
    return
