root = exports ? this

ShowHideCheckboxesModule =

  expandOnLoad: ->
    $('input.show-hide-checkbox:checkbox').each ->
      $(this).parents('label').toggleClass('selected', $(this).is(':checked'));
      if $(this).is(':checked')
        $('#' + $(this).data('section') + '-only').toggle('hide')

  bindToCheckboxes: ->
    $('input.show-hide-checkbox:checkbox').on 'change', ->
      $('#' + $(this).data('section') + '-only').toggle('hide')

    $('input[type=checkbox]').on 'change', ->
      $(this).parents('label').toggleClass('selected', $(this).is(':checked'));

  setup: ->
    ShowHideCheckboxesModule.bindToCheckboxes()
    ShowHideCheckboxesModule.expandOnLoad()

root.ShowHideCheckboxesModule = ShowHideCheckboxesModule

jQuery ->
  ShowHideCheckboxesModule.setup()
