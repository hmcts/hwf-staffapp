root = exports ? this

IncomeModule =

  showChildrenAndIncomeInputs: ->
    $('#application_income_true').on 'click', ->
      $('#children-and-income').show()

  hideChildrenAndIncomeInputs: ->
    $('#application_income_false').on 'click', ->
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
