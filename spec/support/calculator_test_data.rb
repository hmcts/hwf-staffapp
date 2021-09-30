module CalculatorTestData

  module_function

  def seed_data
    [
      { id: 1, fee: '500', married_status: false, children: '0', income: '0', remit: '100', they_pay: '0', type: 'full' },
      { id: 2, fee: '500', married_status: false, children: '0', income: '1160', remit: '100', they_pay: '0', type: 'full' },
      { id: 3, fee: '500', married_status: false, children: '0', income: '1170', remit: '100', they_pay: '0', type: 'full' },
      { id: 4, fee: '100', married_status: false, children: '0', income: '1185', remit: '95', they_pay: '5', type: 'part' },
      { id: 5, fee: '2150', married_status: false, children: '0', income: '5170', remit: '150', they_pay: '2000', type: 'part' },
      { id: 6, fee: '150', married_status: false, children: '0', income: '1470', remit: '0', they_pay: '150', type: 'none' },
      { id: 7, fee: '2000', married_status: false, children: '0', income: '5170', remit: '0', they_pay: '2000', type: 'none' },
      { id: 8, fee: '125', married_status: false, children: '0', income: '1470', remit: '0', they_pay: '125', type: 'none' },
      { id: 9, fee: '1500', married_status: false, children: '0', income: '5170', remit: '0', they_pay: '1500', type: 'none' },
      { id: 10, fee: '300', married_status: false, children: '0', income: '5200', remit: '0', they_pay: '300', type: 'none' },
      { id: 11, fee: '500', married_status: false, children: '2', income: '0', remit: '500', they_pay: '0', type: 'full' },
      { id: 12, fee: '500', married_status: false, children: '2', income: '1160', remit: '500', they_pay: '0', type: 'full' },
      { id: 13, fee: '1500', married_status: false, children: '2', income: '1700', remit: '1500', they_pay: '0', type: 'full' },
      { id: 14, fee: '100', married_status: false, children: '2', income: '1715', remit: '95', they_pay: '5', type: 'part' },
      { id: 15, fee: '2150', married_status: false, children: '2', income: '5700', remit: '150', they_pay: '2000', type: 'part' },
      { id: 16, fee: '150', married_status: false, children: '2', income: '2350', remit: '0', they_pay: '150', type: 'none' },
      { id: 17, fee: '2000', married_status: false, children: '2', income: '5700', remit: '0', they_pay: '2000', type: 'none' },
      { id: 18, fee: '125', married_status: false, children: '2', income: '2175', remit: '0', they_pay: '125', type: 'none' },
      { id: 19, fee: '1500', married_status: false, children: '2', income: '5700', remit: '0', they_pay: '1500', type: 'none' },
      { id: 20, fee: '300', married_status: false, children: '2', income: '5730', remit: '0', they_pay: '300', type: 'none' },
      { id: 21, fee: '500', married_status: true, children: '0', income: '0', remit: '500', they_pay: '0', type: 'full' },
      { id: 22, fee: '500', married_status: true, children: '0', income: '1335', remit: '500', they_pay: '0', type: 'full' },
      { id: 23, fee: '500', married_status: true, children: '0', income: '1345', remit: '500', they_pay: '0', type: 'full' },
      { id: 24, fee: '100', married_status: true, children: '0', income: '1360', remit: '95', they_pay: '5', type: 'part' },
      { id: 25, fee: '2150', married_status: true, children: '0', income: '5345', remit: '150', they_pay: '2000', type: 'part' },
      { id: 26, fee: '150', married_status: true, children: '0', income: '1645', remit: '0', they_pay: '150', type: 'none' },
      { id: 27, fee: '2000', married_status: true, children: '0', income: '5345', remit: '0', they_pay: '2000', type: 'none' },
      { id: 28, fee: '125', married_status: true, children: '0', income: '1645', remit: '0', they_pay: '125', type: 'none' },
      { id: 29, fee: '1500', married_status: true, children: '0', income: '5345', remit: '0', they_pay: '1500', type: 'none' },
      { id: 30, fee: '300', married_status: true, children: '0', income: '5375', remit: '0', they_pay: '300', type: 'none' },
      { id: 31, fee: '500', married_status: true, children: '2', income: '0',    remit: '500', they_pay: '0', type: 'full' },
      { id: 32, fee: '500', married_status: true, children: '2', income: '1135', remit: '500', they_pay: '0', type: 'full' },
      { id: 33, fee: '500', married_status: true, children: '2', income: '1875', remit: '500', they_pay: '0', type: 'full' },
      { id: 34, fee: '100', married_status: true, children: '2', income: '1890', remit: '500', they_pay: '5', type: 'part' },
      { id: 35, fee: '2150', married_status: true, children: '2', income: '5875', remit: '500', they_pay: '2000', type: 'part' },
      { id: 36, fee: '150', married_status: true, children: '2', income: '2175', remit: '500', they_pay: '150', type: 'none' },
      { id: 37, fee: '2000', married_status: true, children: '2', income: '5875', remit: '500', they_pay: '2000', type: 'none' },
      { id: 38, fee: '125', married_status: true, children: '2', income: '2350', remit: '500', they_pay: '125', type: 'none' },
      { id: 39, fee: '1500', married_status: true, children: '2', income: '5875', remit: '500', they_pay: '1500', type: 'none' },
      { id: 40, fee: '300', married_status: true, children: '2', income: '5905', remit: '500', they_pay: '300', type: 'none' }
    ]
  end
end
