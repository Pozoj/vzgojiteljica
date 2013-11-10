$ ->
  if $('#flash').length > 0
    $('#flash').slideDown()

    setTimeout ->
      $('#flash').slideUp()
    , 12000