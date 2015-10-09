root = exports ? this

class incomeCalculator

  # preset values
  min_val = 1085
  uplift_per_child = 245
  couple_supp = 160

  calculate: (fee, status, children, income) ->
    child_uplift = children * uplift_per_child
    curr_fee = parseFloat(fee)
    married_supp = if status=='true' or status==true then couple_supp else 0

    max_cont = Math.max(Math.floor((income - ( min_val + child_uplift + married_supp))/10,0)*10*0.5,0)
    user_to_pay = Math.min(max_cont, curr_fee)

    if user_to_pay == 0
      result = { type: 'full', to_pay: '£0' }
    else if user_to_pay == curr_fee
      result = { type: 'none', to_pay: this.formatCurrency(user_to_pay) }
    else if user_to_pay > 0 and user_to_pay < curr_fee
      result = { type: 'part', to_pay: this.formatCurrency(user_to_pay) }
    else
      result = { type: 'error', to_pay: '' }
    return result

  checkValidation = ->
    $('input[data-check]').each ->
      test = $(this)
      error = $('label.error[data-check-error=' + test.data('check') + ']')
      parent = error.parents('.form-group').children('div')
      if test.val().length == 0 or test.is(':radio') and $('input[name=' + test.attr('name') + ']:checked').val() == undefined
        error.removeClass 'hide'
        parent.addClass 'field_with_errors'
      else
        error.addClass 'hide'
        parent.removeClass 'field_with_errors'

      return
    $('label.error:visible').length == 0

  formatCurrency: (val, dec = 2) ->
    result = parseFloat(val).toFixed(dec).replace(/\.0{2}/,'');
    return '£' + result

  showResult = (data) ->
    add_class = 'callout-' + data.type
    show_text = '\u2713\u00a0 The applicant doesn’t have to pay the fee'
    switch data.type
      when 'none'
        show_text = '\u2717\u00a0 The applicant must pay the full fee'
      when 'part'
        show_text = 'The applicant must pay ' + data.to_pay + ' towards the fee'

    $('#calculator.callout').removeClass('callout-none callout-part callout-full')
    $('#calculator.callout').addClass(add_class)
    $('h3#fee-remit').text show_text
    $('#confirm_fee').text incomeCalculator.prototype.formatCurrency($('#fee').val())
    $('#confirm_status').text $('input:radio[name=couple]:checked').parent().text()
    $('#confirm_children').text $('#children').val()
    $('#confirm_income').text incomeCalculator.prototype.formatCurrency($('#income').val())
    $('#r2_calculator_result').show()
    $('#r2_calculator_income').hide()

  setupPage: ->
    $('#r2_calculator_result').hide()
    $('#r2_calculator :input').attr 'disabled', false
    $('#json-result').hide()
    $('#check_btn').show()
    $('#clear_btn').hide()
    $('#fee').val ''
    $('#children').val ''
    $('#income').val ''
    $('#couple-yes').prop 'checked', false
    $('#couple-no').prop 'checked', false
    $('.error').addClass 'hide'
    return

  setup: ->
    this.setupPage()
    $('#check_btn').on 'click', ->
      if checkValidation()
        result = incomeCalculator.prototype.calculate($('#fee').val(), $('input:radio[name=couple]:checked').val(), $('#children').val(), $('#income').val())
        showResult(result)
      return

root.incomeCalculator = incomeCalculator

jQuery ->
  calc = new(incomeCalculator)
  calc.setup()
