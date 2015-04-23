
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
