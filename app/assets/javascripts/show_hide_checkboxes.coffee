root = exports ? this

ShowHideCheckboxesModule =

  expandOnLoad: ->
    $('input.show-hide-checkbox:checkbox').each ->
      if $(this).is(':checked')
        $('#' + $(this).data('section') + '-only').toggle('hide')

  bindToCheckboxes: ->
    $('input.show-hide-checkbox:checkbox').on 'change', ->
      $('#' + $(this).data('section') + '-only').toggle('hide')

  setup: ->
    ShowHideCheckboxesModule.bindToCheckboxes()
    ShowHideCheckboxesModule.expandOnLoad()

root.ShowHideCheckboxesModule = ShowHideCheckboxesModule

jQuery ->
  ShowHideCheckboxesModule.setup()
