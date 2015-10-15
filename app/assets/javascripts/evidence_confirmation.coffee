root = exports ? this

EvidenceConfirmationModule =
  showReasonInput: ->
    $('#accuracy-form input[id*="correct_false"]').on 'click', ->
      $('#reason-input').show()
    $('#accuracy-form input[id*="correct_true"]').on 'click', ->
      $('#reason-input').hide()

  setup: ->
    if $('#accuracy-form input[id*="correct_false"]').is(':checked')
      $('#reason-input').show()
    else
      $('#reason-input').hide()

    EvidenceConfirmationModule.showReasonInput()

root.EvidenceConfirmationModule = EvidenceConfirmationModule

jQuery ->
  EvidenceConfirmationModule.setup()
