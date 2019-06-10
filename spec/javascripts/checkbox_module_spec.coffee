#= require radio_checkbox_module

describe "RadioAndCheckboxModule", ->
  element=null
  beforeEach ->
    element= $("""
      <div class="row">
        <div class="small-12 medium-8 large-5 columns">
          <div class="options radio">
            <div class="option">
              <label for="application_refund">
                <input name="application[refund]" type="hidden" value="0">
                <input class="show-hide-checkbox" data-section="refund" type="checkbox" value="1" name="application[refund]" id="application_refund">
                This is a refund case
              </label>
            </div>
          </div>
        </div>
      </div>
      <div class="start-hidden" id="refund-only" style="display: none;">
        <div class="row">
          <div class="small-12 medium-8 large-5 columns">
            <div class="form-group panel-indent">
              <label for="application_date_fee_paid">Date fee paid</label>
              <input class="govuk-input" type="text" value="01/07/2015" name="application[date_fee_paid]" id="application_date_fee_paid">
            </div>
          </div>
        </div>
      </div>
    """)
    $(document.body).append(element)
    window.moj.Modules.RadioAndCheckboxModule.init()
    @checkbox = $('#application_refund')
    @label = @checkbox.parent('label')
    @sub_section = $('#refund-only')

  afterEach ->
    element.remove()
    element = null

  describe 'initial view', ->
    describe 'when the value is false', ->
      it 'leaves the checkbox un-checked', ->
        expect(@checkbox.is(':checked')).toBe false

      it 'checkbox label should not be selected', ->
        expect(@label.hasClass('selected')).toBe false

      it 'hides the sub section', ->
        expect($(@sub_section).is(':visible')).toBe false

    describe 'when the value is true', ->
      beforeEach ->
        @checkbox.prop('checked', true)
        window.moj.Modules.RadioAndCheckboxModule.init()

      it 'checkbox label should be selected', ->
        expect(@label.hasClass('selected')).toBe true

      it 'shows the sub section', ->
        expect($(@sub_section).is(':visible')).toBe true


  describe 'when clicking a checkbox', ->
    beforeEach -> @checkbox.trigger('click')

    it 'checkbox is checked', ->
      expect(@checkbox.is(':checked')).toBe true

    it 'applies a selected class to the associated label', ->
      expect(@label.hasClass('selected')).toBe true

    it 'shows the sub section', ->
      expect($(@sub_section).is(':visible')).toBe true

    describe 'and clicking again', ->
      beforeEach -> @checkbox.trigger('click')

      it 'un-checks the checkbox', ->
        expect(@checkbox.is(':checked')).toBe false

      it 'checkbox label should not be selected', ->
        expect(@label.hasClass('selected')).toBe false

      it 're-hides the sub section', ->
        expect($(@sub_section).is(':visible')).toBe false
