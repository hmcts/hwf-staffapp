# set values
$min_val = 1085
$pp_child = 245
$couple_supp = 160

# global variables
$low_threshold = 0
$high_threshold = 0
$income = 0

calculate = ->
  $children_val = $('#children').val() * $pp_child
  $add_single_supp = if $('input:radio[name=couple]').val() == 'false' then 0 else $couple_supp
  $curr_fee = parseFloat($('#fee').val())
  $income = $('#income').val()
  $low_threshold = $min_val + $children_val + $add_single_supp
  $high_threshold = $low_threshold + Math.min(4000, $curr_fee * 2)
  if fullRemittance()
    $('#fee-payable').text '£0'
    $('#fee-remit').text formatCurrency($curr_fee)
  else if $income > $high_threshold
    $('#fee-payable').text formatCurrency($curr_fee)
    $('#fee-remit').text '£0'
  else
    $check_val = $income - $low_threshold
    $max_to_pay = Math.min(Math.max(Math.floor($check_val / 10) * 10 * 0.5, 0), $curr_fee)
    $remittance = Math.max($curr_fee - $max_to_pay, 0)
    $('#fee-payable').text formatCurrency($max_to_pay)
    $('#fee-remit').text formatCurrency($remittance)

  sendToDatabase $remittance, $max_to_pay
  $('.panel.callout').show()
  $('#check_btn').hide()
  $('#clear_btn').show()
  $('#r2_calculator :input').attr 'disabled', true
  return true

fullRemittance = ->
  return ($income < $low_threshold)

formatCurrency = (val) ->
  '£' + val.toFixed(2)

sendToDatabase = (remit, pay) ->
  $.ajax
    method: 'POST'
    url: '/calculator/record_search'
    dataType: 'json'
    data: r2_calculator:
      fee: $('#fee').val()
      married: $('input:radio[name=couple]').val() == 'true'
      children: $('#children').val()
      income: $('#income').val()
      remittance: remit
      to_pay: pay
    success: (data) ->
      $('#json-result').text 'Check recorded'
      false
    error: (data) ->
      $('#json-result').text 'Save failed with ' + data + ' errors'
      alert 'error'
      return
  return

checkValidation = ->
  $('input[data-check]').each ->
    test = $(this)
    error = $('small.error[data-check-error=' + test.data('check') + ']')
    if test.val().length == 0 or test.is(':radio') and $('input[name=' + test.attr('name') + ']:checked').val() == undefined
      error.removeClass 'hide'
    else
      error.addClass 'hide'
    return
  $('small.error:visible').length == 0

setupPage = ->
  $('.panel.callout').hide()
  $('#r2_calculator :input').attr 'disabled', false
  $('#check_btn').show()
  $('#clear_btn').hide()
  $('#fee').val ''
  $('#children').val '0'
  $('#income').val ''
  $('#couple-yes').prop 'checked', false
  $('#couple-no').prop 'checked', false
  $('.error').addClass 'hide'
  return

$(document).ready ->
  setupPage()
  $('#check_btn').on 'click', ->
    if checkValidation()
      calculate()
    return
  $('#clear_btn').on 'click', ->
    setupPage()
    return
  return