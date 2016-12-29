$ ->
  $('#status').hide()
  $('#progress').hide()

  $(FileUploadDOMId).fileupload
    dataType: 'json'
    done: (e, data) ->
      FileUploadVzgojiteljica(e, data)
      $('#status').text('Zaključujem ...')
      $('#progress').hide()
      window.location.href = $('#status').data('redirect')
    progressall: (e, data) ->
      progress = parseInt (data.loaded / data.total) * 100, 10
      $('#progress .bar').css 'width', "#{progress}%"
      $('#progress .percent').text "#{progress}%"
    add: (e, data) ->
      $('#progress').show()
      $('#status').show()
      data.submit()
