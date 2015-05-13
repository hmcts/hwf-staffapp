root = exports ? this

RadioButtonsModule =

  bindToRadioButtons: ->
    $('input[type=radio]').on 'change', ->
      $("[name='" + $(this).attr('name') + "']").parent().removeClass("selected")
      $(this).parent().addClass('selected')

  setup: ->
    RadioButtonsModule.bindToRadioButtons()

root.RadioButtonsModule = RadioButtonsModule

jQuery ->
  RadioButtonsModule.setup()
