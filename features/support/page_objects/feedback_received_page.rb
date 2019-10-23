class FeedbackReceivedPage < BasePage
  section :content, '#content' do
    element :header, 'h1', text: 'Feedback received'
  end
end
