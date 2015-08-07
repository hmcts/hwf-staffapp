//= require income

describe "IncomeModule", ->
  element = null
  beforeEach ->
    element = $("""
    <div id="application_income_true"/>
    <div id="application_income_false"/>
    <section id="test-section">
      <div id="children-and-income">
        <input data-check="children" id="children" min="0" value="" type="number">
        <input data-check="income" id="income" name="income" value="0" type="number">
      </div>
    </section>
    """)
    $(document.body).append(element)
    @detail = $('#test-section')
    IncomeModule.setup()

  describe 'initial hiding', ->
    it 'hides "#children-and-income"', ->
      expect($('#children-and-income').is(':visible')).toBe(false)

  describe 'when the user selects "Yes" answer for dependant children question', ->
    it 'shows #children-and-income', ->
      $('#application_income_true').trigger('click')
      expect($('#children-and-income').is(':visible')).toBe(true)

  describe 'when the user selects "No" answer for dependant children question', ->
    it 'hides #children-and-income', ->
      $('#children-and-income').show()
      $('#application_income_false').trigger('click')
      expect($('#children-and-income').is(':visible')).toBe(false)

  describe 'input form values', ->
    describe 'initial values', ->
      it 'income amount', ->
        expect($('#income').val()).toBe('0')

      it 'number of children', ->
        expect($('#children').val()).toBe('')

    describe 'when the "Yes" option is chosen', ->
      beforeEach ->
        $('#application_income_true').trigger('click')

      describe 'and the number of children & income is declared', ->
        beforeEach ->
          $('#income').val(5000)
          $('#children').val(1)

        describe 'and the "No" option is chosen', ->
          beforeEach ->
            $('#application_income_false').trigger('click')

          it 'blanks out income value', ->
            expect($('#income').val()).toBe('0')

          it 'blanks out children value', ->
            expect($('#children').val()).toBe('')
