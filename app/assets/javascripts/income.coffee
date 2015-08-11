root = exports ? this

IncomeModule =
  showIncomeInput: ->
    $('input[id*="application_dependents"]').on 'click', ->
      $('#income-input').show()

  setup: ->
    if $('input[id*="application_dependents"]').is(':checked')
      if $('#application_dependents_true').is(':checked')
        $('#children-only').show()
      $('#income-input').show()
    else
      $('#children-only').hide()
      $('#income-input').hide()

    IncomeModule.showIncomeInput()

root.IncomeModule = IncomeModule

jQuery ->
  IncomeModule.setup()
