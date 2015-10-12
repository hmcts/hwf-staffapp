#= require radio_buttons_module
#= require evidence_confirmation

describe "EvidenceConfirmationModule", ->
  element = null
  beforeEach ->
    element = $("""<div class="small-12 medium-8 large-5 columns">
    <div class="form-group">
      <div class="row collapse">
        <div class="columns small-12">
          <label for="evidence_correct">Is the evidence correct?</label>
          <div class="options radio">
            <div class="option">
              <label for="evidence_correct_false">
                <input type="radio" value="false" name="evidence[correct]" id="evidence_correct_false">
                  No
               </label>
            </div>
            <div class="option">
              <label for="evidence_correct_true">
                <input type="radio" value="true" name="evidence[correct]" id="evidence_correct_true">
                Yes
              </label>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div class="panel-indent form-group row collapse" id="reason-input" style="display: none;">
      <div class="columns small-12">
        <label for="evidence_reason">What is incorrect about the evidence?</label>
          <textarea rows="3" name="evidence[reason]" id="evidence_reason"></textarea>
        </div>
      </div>
    </div>""")
    $(document.body).append(element)
    EvidenceConfirmationModule.setup()
    window.RadioButtonsModule.setup()
    @yes_button = $('#evidence_correct_true')
    @yes_label = @yes_button.parent('label')
    @no_button = $('#evidence_correct_false')
    @no_label = @no_button.parent('label')
    @reason_section = $('#reason-input')
    @reason = $('#evidence_reason')

  afterEach ->
    element.remove()
    element = null

  describe 'initial view', ->
    it 'neither label should be selected', ->
      expect(@yes_label.hasClass('selected')).toBe false
      expect(@no_label.hasClass('selected')).toBe false

    it 'evidence reason section is hidden', ->
      expect($(@reason_section).is(':visible')).toBe false

  describe 'when the "No" option is chosen', ->
    beforeEach ->
      @no_button.trigger('click')

    it 'adds a selected class to the "No" label', ->
      expect(@no_label.hasClass('selected')).toBe true

    it 'evidence reason section is shown', ->
      expect(@reason_section.is(':visible')).toBe true

    describe 'when the "Yes" option is chosen subsequently', ->
      beforeEach ->
        @reason.append('EXPLANATION')
        @yes_button.trigger('click')

      it 'removes the reason text', ->
        expect(@reason_section.is(':visible')).toBe false

      it 'removes the reason explanation', ->
        expect(@reason.val()).toEqual ""
