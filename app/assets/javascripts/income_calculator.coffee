root = exports ? this

class IncomeCalculator

  # preset values
  min_val = 1085
  pp_child = 245
  couple_supp = 160

  calculate = (fee, status, children, income) ->
    child_uplift = children * pp_child
    curr_fee = parseFloat(fee)
    married_supp = if status=='true' or status==true then couple_supp else 0

    max_cont = Math.max(Math.floor((income - ( min_val + child_uplift + married_supp))/10,0)*10*0.5,0)
    user_to_pay = Math.min(max_cont, curr_fee)

    if user_to_pay == 0
      result = { type: 'full', to_pay: '£0' }
    else if user_to_pay == curr_fee
      result = { type: 'none', to_pay: formatCurrency(user_to_pay) }
    else if user_to_pay > 0 and user_to_pay < curr_fee
      result = { type: 'part', to_pay: formatCurrency(user_to_pay) }
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

  formatCurrency = (val) ->
    return '£' + val.toFixed(2)

  showResult = (data) ->
    add_class = 'callout-passed'
    show_text = 'The applicant has £0 to pay'
    switch data.type
      when 'none'
        add_class = 'callout-warning'
        show_text = 'The applicant must pay the full fee'
      when 'part'
        show_text = 'The applicant must pay ' + data.to_pay + ' towards the fee'

    $('#result.callout').addClass(add_class)
    $('span#fee-remit').text show_text
    $('#result.callout').show()


  setupPage: ->
    console.log 'Hits setupPage'
    $('#result.callout').hide()
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
    console.log 'Hit setup'
    this.setupPage()
    $('#check_btn').on 'click', ->
      if checkValidation()
        console.log "Sending #{$('input:radio[name=couple]:checked').val()} to calculate"
        result = calculate($('#fee').val(), $('input:radio[name=couple]:checked').val(), $('#children').val(), $('#income').val())
        showResult(result)
      return

root.IncomeCalculator = IncomeCalculator

jQuery ->
  console.log 'jQuery starts'
  calc = new(IncomeCalculator)
  calc.setup()
