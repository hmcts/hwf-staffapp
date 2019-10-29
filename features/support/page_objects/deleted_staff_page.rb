class DeletedStaffPage < BasePage
  section :content, '#content' do
    element :header, 'h1', text: 'Deleted staff'
  end
end
