$ ->
  $('.rowlinks').on 'click', 'tbody tr', (e) ->
    e.stopPropagation()
    url = $(this).find('a').first().attr('href')

    if event.metaKey
      window.open(url)
    else
      window.location.href = url
