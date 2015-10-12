root = exports ? this

EvidenceConfirmationModule =
  showReasonInput: ->
    $('input[id*="evidence_correct_false"]').on 'click', ->
      $('#reason-input').show()
    $('input[id*="evidence_correct_true"]').on 'click', ->
      $('#reason-input').hide()
      $('#evidence_reason').val("")

  setup: ->
    if $('input[id*="evidence_correct_false"]').is(':checked')
      $('#reason-input').show()
    else
      $('#reason-input').hide()

    EvidenceConfirmationModule.showReasonInput()

root.EvidenceConfirmationModule = EvidenceConfirmationModule

jQuery ->
  EvidenceConfirmationModule.setup()
