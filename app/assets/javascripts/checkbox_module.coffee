root = exports ? this

CheckboxModule =

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
    CheckboxModule.bindToCheckboxes()
    CheckboxModule.expandOnLoad()

root.CheckboxModule = CheckboxModule

jQuery ->
  CheckboxModule.setup()
