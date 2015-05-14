root = exports ? this

class IncomeCalculator

  # preset values
  min_val = 1085
  pp_child = 245
  couple_supp = 160

  # variables
  low_threshold = 0
  high_threshold = 0
  income = 0

  calculate: (fee, status, children, income) ->
    return { type: 'full', to_pay: '£0' }


  formatCurrency: (val) ->
    return '£' + val.toFixed(2)

  setupPage: ->
    $('.panel.callout').hide()
    $('#r2_calculator :input').attr 'disabled', false
    $('#json-result').hide()
    $('#check_btn').show()
    $('#clear_btn').hide()
    $('#fee').val ''
    $('#children').val '0'
    $('#income').val ''
    $('#couple-yes').prop 'checked', false
    $('#couple-no').prop 'checked', false
    $('.error').addClass 'hide'
    return

  setup: ->
    IncomeCalculator.setupPage()

root.IncomeCalculator = IncomeCalculator

jQuery ->
  IncomeCalculator.setup
