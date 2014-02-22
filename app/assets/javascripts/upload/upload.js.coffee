$ ->
  $('.submit input').hide()
  $('#progress').hide()

  $(FileUploadDOMId).fileupload
    dataType: 'json'
    done: (e, data) ->
      FileUploadVzgojiteljica(e, data)
      $('.submit input').attr('disabled', false).click().attr('disabled', true).val('Zaključujem ...')
      $('#progress').hide()
    progressall: (e, data) ->
      progress = parseInt (data.loaded / data.total) * 100, 10
      $('#progress .bar').css 'width', "#{progress}%"
      $('#progress .percent').text "#{progress}%"
    add: (e, data) ->
      $('#progress').show()
      $('.submit input').show()
      data.submit()
