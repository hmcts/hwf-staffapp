root = exports ? this

IncomeModule =

  showChildrenAndIncomeInputs: ->
    $('#application_dependents_true').on 'click', ->
      $('#children-and-income').show()

  hideChildrenAndIncomeInputs: ->
    $('#application_dependents_false').on 'click', ->
      $('#children').val('')
      $('#income').val(0)
      $('#children-and-income').hide()

  setup: ->
    $('#children-and-income').hide()
    IncomeModule.showChildrenAndIncomeInputs()
    IncomeModule.hideChildrenAndIncomeInputs()

root.IncomeModule = IncomeModule

jQuery ->
  IncomeModule.setup()
