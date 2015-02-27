$ ->
  $('.rowlinks').on 'click', 'tbody tr', (e) ->
    e.stopPropagation()
    window.location.href = $(this).find('a').first().attr('href')
