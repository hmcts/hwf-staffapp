class ProcessOnlineApplicationPage < BasePage
  set_url '/online_applications/1/edit'

  section :content, '#content' do
    element :header, 'h1', text: 'Application details'
    sections :group, '.group-level' do
      elements :input, 'input'
    end
  end
end
