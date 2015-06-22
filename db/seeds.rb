Office.create([{ name: 'Digital' },
               { name: 'Bristol' }])

User.create([{
              name: 'Admin',
              email: 'fee-remission@digital.justice.gov.uk',
              password: '123456789',
              role: 'admin',
              office_id: 1
            },
            {
              name: 'User',
              email: 'bristol.user@hmcts.gsi.gov.uk',
              password: '987654321',
              role: 'user',
              office_id: 2
            }
            ])

Jurisdiction.create([{ name: 'County Court', abbr: nil },
                     { name: 'High Court', abbr: nil },
                     { name: 'Insolvency', abbr: nil },
                     { name: 'Family SFC', abbr: nil },
                     { name: 'Probate', abbr: nil },
                     { name: 'Court of Protection', abbr: 'COP' },
                     { name: 'Magistrates Civil', abbr: nil },
                     { name: 'Gambling', abbr: nil },
                     { name: 'Employment Tribunal', abbr: nil },
                     { name: 'Gender Tribunal', abbr: nil },
                     { name: 'Land & Property Chamber', abbr: nil },
                     { name: 'Immigration Appeal Chamber', abbr: 'IAC' },
                     { name: 'Upper Tribunal Immigration Appeal Chamber', abbr: 'UTIAC' }])
