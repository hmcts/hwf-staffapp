root = exports ? this

ShowHideCheckboxesModule =

  expandOnLoad: ->
    $('input.show-hide-checkbox:checkbox').each ->
      $('#' + $(this).data('section') + '-only').toggle($(this).is(':checked'))

    $('input[type=checkbox]').each ->
      $(this).parents('label').toggleClass('selected', $(this).is(':checked'))

  bindToCheckboxes: ->
    $('input.show-hide-checkbox:checkbox').on 'change', ->
      $('#' + $(this).data('section') + '-only').toggle($(this).is(':checked'))

    $('input[type=checkbox]').on 'change', ->
      $(this).parents('label').toggleClass('selected', $(this).is(':checked'))

  setup: ->
    ShowHideCheckboxesModule.bindToCheckboxes()
    ShowHideCheckboxesModule.expandOnLoad()

root.ShowHideCheckboxesModule = ShowHideCheckboxesModule

jQuery ->
  ShowHideCheckboxesModule.setup()
