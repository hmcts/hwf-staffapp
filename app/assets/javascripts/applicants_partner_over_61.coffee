root = exports ? this

ApplicantsPartnerOver61 =
  clearOptions: ->
    $('#application_threshold_exceeded_false').on 'click', ->
      $('#application_partner_over_61_true').prop 'checked', false
      $('#application_partner_over_61_false').prop 'checked', false

root.ApplicantsPartnerOver61 = ApplicantsPartnerOver61

jQuery ->
  ApplicantsPartnerOver61.clearOptions()
