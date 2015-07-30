root = exports ? this

RadioButtonsModule =

  expandOnLoad: ->
    $('input.show-hide-section:radio').each ->
      if $(this).is(':checked')
        $('#' + $(this).data('section') + '-only').toggle($(this).data('show'))

  bindToRadioButtons: ->
    $('input.show-hide-section:radio').on 'change', ->
      $('#' + $(this).data('section') + '-only').toggle($(this).data('show'))

    $('input[type=radio]').on 'change', ->
      $("[name='" + $(this).attr('name') + "']").parents('label').removeClass("selected")
      $(this).parents('label').addClass('selected')

  setup: ->
    RadioButtonsModule.bindToRadioButtons()
    RadioButtonsModule.expandOnLoad()

root.RadioButtonsModule = RadioButtonsModule

jQuery ->
  RadioButtonsModule.setup()
