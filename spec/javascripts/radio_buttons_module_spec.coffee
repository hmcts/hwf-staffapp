#= require radio_buttons_module

describe "RadioButtonsModule", ->
  element=null
  beforeEach ->
    element= $("""
      <style>
        .start-hidden {
          display: none;
        }
      </style>
      <div class="row">
        <div class="small-12 medium-8 large-5 columns">
          <div class="form-group">
            <div class="row collapse">
              <div class="columns small-12">
                <label for="exceeded">The applicant and their partner have</label>
                <div class="options radio">
                  <div class="option">
                    <label for="exceeded_false">
                      <input class="show-hide-section" data-section="over-61" type="radio" name="exceeded" id="exceeded_false" data-show="false" value="false">
                      Less than this amount
                    </label>
                  </div>
                  <div class="option">
                    <label for="exceeded_true">
                      <input class="show-hide-section" data-section="over-61" type="radio" name="exceeded" id="exceeded_true" data-show="true" value="true">
                      More than this amount
                    </label>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div class="start-hidden" id="over-61-only" style="display: none;">
        <div class="row">
          <span>Some data</span>
        </div>
      </div>
    """)
    $(document.body).append(element)
    window.moj.Modules.RadioButtonsModule.init()
    @true_button = $('#exceeded_true')
    @true_label = @true_button.parent('label')
    @false_button = $('#exceeded_false')
    @false_label = @false_button.parent('label')
    @sub_section = $('#over-61-only')

  afterEach ->
    element.remove()
    element = null

  describe 'initial view', ->
    it 'neither label should be selected', ->
      expect(@true_label.hasClass('selected')).toBe false
      expect(@false_label.hasClass('selected')).toBe false

    it 'hides the sub section', ->
      expect($(@sub_section).is(':visible')).toBe false

  describe 'when clicking the hide option', ->
    beforeEach -> @false_button.trigger('click')

    it 'adds a selected class to the correct label', ->
      expect(@false_label.hasClass('selected')).toBe true

    it 'leaves the sub section hidden', ->
      expect($(@sub_section).is(':visible')).toBe false

  describe 'when clicking the show option', ->
    beforeEach -> @true_button.trigger('click')

    it 'adds a selected class to the correct label', ->
      expect(@true_label.hasClass('selected')).toBe true

    it 'shows the sub section', ->
      expect($(@sub_section).is(':visible')).toBe true
