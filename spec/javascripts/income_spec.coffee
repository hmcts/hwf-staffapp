#= require radio_buttons_module
#= require income

describe "IncomeModule", ->
  element = null
  beforeEach ->
    element = $("""
    <div class="small-12 medium-8 large-5 columns">
      <div class="form-group">
        <div class="options radio">
          <div class="option">
            <label for="application_dependents_false">
              <input class="show-hide-section" data-section="children" data-show="false" type="radio" value="false" name="application[dependents]" id="application_dependents_false">
              No
            </label>
          </div>
          <div class="option">
            <label for="application_dependents_true">
              <input class="show-hide-section" data-section="children" data-show="true" type="radio" value="true" name="application[dependents]" id="application_dependents_true">
              Yes
            </label>
          </div>
        </div>
      </div>
      <div class="row collapse panel-indent" id="children-only">
        <div class="small-12 medium-6 large-5 columns form-group">
          <label for="application_children">Children</label>
          <div class="row collapse">
            <div class="columns small-4 medium-4 large-4">
              <input type="text" name="application[children]" id="application_children">
            </div>
          </div>
        </div>
      </div>
      <div class="row collapse panel-indent" id="income-input">
        <div class="small-12 medium-6 large-5 columns form-group">
          <label for="application_income">Income</label>
          <div class="row collapse prefix-radius">
            <div class="small-2 medium-4 large-3 columns">
              <span class="prefix"><label class="inline" for="income">£</label></span>
            </div>
            <div class="small-10 medium-8 large-9 columns">
              <input type="text" name="application[income]" id="application_income">
            </div>
          </div>
        </div>
      </div>
    </div>
    """)
    $(document.body).append(element)
    IncomeModule.setup()
    window.RadioButtonsModule.setup()

  afterEach ->
    element.remove()
    element = null

  describe 'on initial load', ->
    describe 'when children is checked', ->
      beforeEach ->
        $('#application_dependents_true').prop('checked', true)
        window.RadioButtonsModule.setup()

      it 'shows children field', ->
        expect($('#application_children').is(':visible')).toBe(true)

  describe 'on initial load', ->
    beforeEach ->
      $('#application_dependents_false').prop('checked', false)
      $('#application_dependents_true').prop('checked', false)
      window.RadioButtonsModule.setup()

    describe 'no choice is made', ->
      describe 'sets initial value', ->
        it 'income amount to empty ', ->
          expect($('#application_income').val()).toBe('')

        it 'number of children to empty', ->
          expect($('#application_children').val()).toBe('')

      it 'hides income field', ->
        expect($('#application_income').is(':visible')).toBe(false)

      it 'hides children field', ->
        expect($('#application_children').is(':visible')).toBe(false)

  describe 'when the user selects "Yes" answer for dependant children question', ->
    beforeEach ->
      $('#application_dependents_true').trigger('click')

    it 'shows children field', ->
      expect($('#application_children').is(':visible')).toBe(true)
    it 'shows the income field', ->
      expect($('#application_income').is(':visible')).toBe(true)

  describe 'when the user selects "No" answer for dependant children question', ->
    beforeEach ->
      $('#application_dependents_false').trigger('click')

    it 'hides children field', ->
      expect($('#application_children').is(':visible')).toBe(false)
    it 'shows the income field', ->
      expect($('#application_income').is(':visible')).toBe(true)
