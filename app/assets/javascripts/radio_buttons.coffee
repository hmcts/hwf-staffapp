root = exports ? this

RadioButtonsModule =

  bindToRadioButtons: ->
    $('input[type=radio]').on 'change', ->
      $("[name='" + $(this).attr('name') + "']").parents('label').removeClass("selected")
      $(this).parents('label').addClass('selected')

  setup: ->
    RadioButtonsModule.bindToRadioButtons()

root.RadioButtonsModule = RadioButtonsModule

jQuery ->
  RadioButtonsModule.setup()
