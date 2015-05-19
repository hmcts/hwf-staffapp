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

    it 'parses all seed data', ->
      calc = new incomeCalculator
      for t in seed_data
        match = calc.calculate(t.fee, t.married_status, t.children, t.income)
        expect(match.type).toEqual(t.type)
        expect(match.they_pay).toEqual(t.to_pay)

seed_data = [
  { fee: '100', married_status: true, children: '0', income: '100', remit: '100', they_pay: '0', type: 'full', },
  { fee: '100', married_status: true, children: '0', income: '1200', remit: '100', they_pay: '0', type: 'full', },
  { fee: '100', married_status: true, children: '0', income: '1300', remit: '75', they_pay: '25', type: 'part', },
  { fee: '100', married_status: true, children: '0', income: '3000', remit: '0', they_pay: '100', type: 'none', },
  { fee: '100', married_status: true, children: '1', income: '100', remit: '100', they_pay: '0', type: 'full', },
  { fee: '100', married_status: true, children: '1', income: '1500', remit: '95', they_pay: '5', type: 'part', },
  { fee: '100', married_status: false, children: '2', income: '1500', remit: '100', they_pay: '0', type: 'full', },
  { fee: '100', married_status: true, children: '1', income: '3000', remit: '0', they_pay: '100', type: 'none', },
  { fee: '100', married_status: true, children: '2', income: '100', remit: '100', they_pay: '0', type: 'full', },
  { fee: '410', married_status: true, children: '1', income: '1500', remit: '405', they_pay: '5', type: 'part', },
  { fee: '410', married_status: false, children: '2', income: '1500', remit: '410', they_pay: '0', type: 'full', },
  { fee: '100', married_status: true, children: '2', income: '3000', remit: '0', they_pay: '100', type: 'none', },
  { fee: '100', married_status: true, children: '3', income: '100', remit: '100', they_pay: '0', type: 'full', },
  { fee: '100', married_status: true, children: '3', income: '1900', remit: '100', they_pay: '0', type: 'full', },
  { fee: '100', married_status: false, children: '3', income: '1900', remit: '60', they_pay: '40', type: 'part', },
  { fee: '100', married_status: true, children: '3', income: '3000', remit: '0', they_pay: '100', type: 'none', },
  { fee: '100', married_status: true, children: '4', income: '100', remit: '100', they_pay: '0', type: 'full', },
  { fee: '100', married_status: true, children: '4', income: '2200', remit: '100', they_pay: '0', type: 'full', },
  { fee: '100', married_status: true, children: '4', income: '2300', remit: '65', they_pay: '35', type: 'part', },
  { fee: '100', married_status: true, children: '4', income: '3000', remit: '0', they_pay: '100', type: 'none', },
  { fee: '100', married_status: true, children: '5', income: '100', remit: '100', they_pay: '0', type: 'full', },
  { fee: '100', married_status: true, children: '5', income: '2400', remit: '100', they_pay: '0', type: 'full', },
  { fee: '100', married_status: true, children: '5', income: '2500', remit: '85', they_pay: '15', type: 'part', },
  { fee: '100', married_status: true, children: '5', income: '3000', remit: '0', they_pay: '100', type: 'none', },
  { fee: '100', married_status: true, children: '6', income: '100', remit: '100', they_pay: '0', type: 'full', },
  { fee: '100', married_status: true, children: '6', income: '2700', remit: '100', they_pay: '0', type: 'full', },
  { fee: '100', married_status: true, children: '6', income: '2800', remit: '60', they_pay: '40', type: 'part', },
  { fee: '100', married_status: true, children: '6', income: '3000', remit: '0', they_pay: '100', type: 'none', },
  { fee: '100', married_status: false, children: '0', income: '100', remit: '100', they_pay: '0', type: 'full', },
  { fee: '100', married_status: false, children: '0', income: '1000', remit: '100', they_pay: '0', type: 'full', },
  { fee: '100', married_status: false, children: '0', income: '1100', remit: '95', they_pay: '5', type: 'part', },
  { fee: '100', married_status: false, children: '0', income: '3000', remit: '0', they_pay: '100', type: 'none', },
  { fee: '100', married_status: false, children: '1', income: '100', remit: '100', they_pay: '0', type: 'full', },
  { fee: '100', married_status: false, children: '1', income: '1300', remit: '100', they_pay: '0', type: 'full', },
  { fee: '100', married_status: false, children: '1', income: '1400', remit: '65', they_pay: '35', type: 'part', },
  { fee: '100', married_status: false, children: '1', income: '3000', remit: '0', they_pay: '100', type: 'none', },
  { fee: '100', married_status: false, children: '2', income: '100', remit: '100', they_pay: '0', type: 'full', },
  { fee: '100', married_status: true, children: '1', income: '1600', remit: '45', they_pay: '55', type: 'part', },
  { fee: '100', married_status: false, children: '2', income: '1600', remit: '90', they_pay: '10', type: 'part', },
  { fee: '100', married_status: false, children: '2', income: '3000', remit: '0', they_pay: '100', type: 'none', },
  { fee: '100', married_status: false, children: '3', income: '100', remit: '100', they_pay: '0', type: 'full', },
  { fee: '410', married_status: true, children: '1', income: '1600', remit: '355', they_pay: '55', type: 'part', },
  { fee: '410', married_status: true, children: '3', income: '1900', remit: '410', they_pay: '0', type: 'full', },
  { fee: '100', married_status: false, children: '3', income: '3000', remit: '0', they_pay: '100', type: 'none', },
  { fee: '100', married_status: false, children: '4', income: '100', remit: '100', they_pay: '0', type: 'full', },
  { fee: '410', married_status: false, children: '3', income: '1900', remit: '370', they_pay: '40', type: 'part', },
  { fee: '100', married_status: false, children: '4', income: '2100', remit: '85', they_pay: '15', type: 'part', },
  { fee: '100', married_status: false, children: '4', income: '3000', remit: '0', they_pay: '100', type: 'none', },
  { fee: '100', married_status: false, children: '5', income: '100', remit: '100', they_pay: '0', type: 'full', },
  { fee: '100', married_status: false, children: '5', income: '2300', remit: '100', they_pay: '0', type: 'full', },
  { fee: '100', married_status: false, children: '5', income: '2400', remit: '55', they_pay: '45', type: 'part', },
  { fee: '100', married_status: false, children: '5', income: '3000', remit: '0', they_pay: '100', type: 'none', },
  { fee: '100', married_status: false, children: '6', income: '100', remit: '100', they_pay: '0', type: 'full', },
  { fee: '100', married_status: false, children: '6', income: '2500', remit: '100', they_pay: '0', type: 'full', },
  { fee: '100', married_status: false, children: '6', income: '2600', remit: '80', they_pay: '20', type: 'part', },
  { fee: '100', married_status: false, children: '6', income: '3000', remit: '0', they_pay: '100', type: 'none', },
  { fee: '410', married_status: true, children: '0', income: '100', remit: '410', they_pay: '0', type: 'full', },
  { fee: '410', married_status: true, children: '0', income: '1200', remit: '410', they_pay: '0', type: 'full', },
  { fee: '410', married_status: true, children: '0', income: '1300', remit: '385', they_pay: '25', type: 'part', },
  { fee: '410', married_status: true, children: '0', income: '3000', remit: '0', they_pay: '410', type: 'none', },
  { fee: '410', married_status: true, children: '1', income: '100', remit: '410', they_pay: '0', type: 'full', },
  { fee: '410', married_status: false, children: '2', income: '1600', remit: '400', they_pay: '10', type: 'part', },
  { fee: '100', married_status: true, children: '2', income: '1700', remit: '100', they_pay: '0', type: 'full', },
  { fee: '410', married_status: true, children: '1', income: '3000', remit: '0', they_pay: '410', type: 'none', },
  { fee: '410', married_status: true, children: '2', income: '100', remit: '410', they_pay: '0', type: 'full', },
  { fee: '410', married_status: true, children: '2', income: '1700', remit: '410', they_pay: '0', type: 'full', },
  { fee: '100', married_status: true, children: '2', income: '1800', remit: '70', they_pay: '30', type: 'part', },
  { fee: '410', married_status: true, children: '2', income: '3000', remit: '0', they_pay: '410', type: 'none', },
  { fee: '410', married_status: true, children: '3', income: '100', remit: '410', they_pay: '0', type: 'full', },
  { fee: '100', married_status: true, children: '3', income: '2000', remit: '90', they_pay: '10', type: 'part', },
  { fee: '100', married_status: false, children: '4', income: '2000', remit: '100', they_pay: '0', type: 'full', },
  { fee: '410', married_status: true, children: '3', income: '3000', remit: '0', they_pay: '410', type: 'none', },
  { fee: '410', married_status: true, children: '4', income: '100', remit: '410', they_pay: '0', type: 'full', },
  { fee: '410', married_status: true, children: '4', income: '2200', remit: '410', they_pay: '0', type: 'full', },
  { fee: '410', married_status: true, children: '4', income: '2300', remit: '375', they_pay: '35', type: 'part', },
  { fee: '410', married_status: true, children: '4', income: '3000', remit: '25', they_pay: '385', type: 'part', },
  { fee: '410', married_status: true, children: '5', income: '100', remit: '410', they_pay: '0', type: 'full', },
  { fee: '410', married_status: true, children: '5', income: '2400', remit: '410', they_pay: '0', type: 'full', },
  { fee: '410', married_status: true, children: '5', income: '2500', remit: '395', they_pay: '15', type: 'part', },
  { fee: '410', married_status: true, children: '5', income: '3000', remit: '145', they_pay: '265', type: 'part', },
  { fee: '410', married_status: true, children: '6', income: '100', remit: '410', they_pay: '0', type: 'full', },
  { fee: '410', married_status: true, children: '6', income: '2700', remit: '410', they_pay: '0', type: 'full', },
  { fee: '410', married_status: true, children: '6', income: '2800', remit: '370', they_pay: '40', type: 'part', },
  { fee: '410', married_status: true, children: '6', income: '3000', remit: '270', they_pay: '140', type: 'part', },
  { fee: '410', married_status: false, children: '0', income: '100', remit: '410', they_pay: '0', type: 'full', },
  { fee: '410', married_status: false, children: '0', income: '1000', remit: '410', they_pay: '0', type: 'full', },
  { fee: '410', married_status: false, children: '0', income: '1100', remit: '405', they_pay: '5', type: 'part', },
  { fee: '410', married_status: false, children: '0', income: '3000', remit: '0', they_pay: '410', type: 'none', },
  { fee: '410', married_status: false, children: '1', income: '100', remit: '410', they_pay: '0', type: 'full', },
  { fee: '410', married_status: false, children: '1', income: '1300', remit: '410', they_pay: '0', type: 'full', },
  { fee: '410', married_status: false, children: '1', income: '1400', remit: '375', they_pay: '35', type: 'part', },
  { fee: '410', married_status: false, children: '1', income: '3000', remit: '0', they_pay: '410', type: 'none', },
  { fee: '410', married_status: false, children: '2', income: '100', remit: '410', they_pay: '0', type: 'full', },
  { fee: '100', married_status: false, children: '3', income: '1800', remit: '100', they_pay: '0', type: 'full', },
  { fee: '410', married_status: true, children: '2', income: '1800', remit: '380', they_pay: '30', type: 'part', },
  { fee: '410', married_status: false, children: '2', income: '3000', remit: '0', they_pay: '410', type: 'none', },
  { fee: '410', married_status: false, children: '3', income: '100', remit: '410', they_pay: '0', type: 'full', },
  { fee: '410', married_status: false, children: '3', income: '1800', remit: '410', they_pay: '0', type: 'full', },
  { fee: '410', married_status: true, children: '3', income: '2000', remit: '400', they_pay: '10', type: 'part', },
  { fee: '410', married_status: false, children: '3', income: '3000', remit: '0', they_pay: '410', type: 'none', },
  { fee: '410', married_status: false, children: '4', income: '100', remit: '410', they_pay: '0', type: 'full', },
  { fee: '410', married_status: false, children: '4', income: '2000', remit: '410', they_pay: '0', type: 'full', },
  { fee: '410', married_status: false, children: '4', income: '2100', remit: '395', they_pay: '15', type: 'part', },
  { fee: '410', married_status: false, children: '4', income: '3000', remit: '0', they_pay: '410', type: 'none', },
  { fee: '410', married_status: false, children: '5', income: '100', remit: '410', they_pay: '0', type: 'full', },
  { fee: '410', married_status: false, children: '5', income: '2300', remit: '410', they_pay: '0', type: 'full', },
  { fee: '410', married_status: false, children: '5', income: '2400', remit: '365', they_pay: '45', type: 'part', },
  { fee: '410', married_status: false, children: '5', income: '3000', remit: '65', they_pay: '345', type: 'part', },
  { fee: '410', married_status: false, children: '6', income: '100', remit: '410', they_pay: '0', type: 'full', },
  { fee: '410', married_status: false, children: '6', income: '2500', remit: '410', they_pay: '0', type: 'full', },
  { fee: '410', married_status: false, children: '6', income: '2600', remit: '390', they_pay: '20', type: 'part', },
  { fee: '410', married_status: false, children: '6', income: '3000', remit: '190', they_pay: '220', type: 'part', }
]