//=require 'income_calculator'

describe "income_calculator", ->

  it 'will convert numbers to currency', ->
    calc = new incomeCalculator
    expect(calc.formatCurrency(12)).toBe('£12')

  describe 'calculator', ->
    it 'will return a json object', ->
      calc = new(incomeCalculator)
      calc.setup()
      expect(calc.calculate('a', 'b','c', 'd')).toEqual({ type: 'error', to_pay: '' })

    it 'will return correct values', ->
      calc = new incomeCalculator
      first_res = calc.calculate(410, false, 2, 2000)
      expect(first_res.type).toEqual('part')
