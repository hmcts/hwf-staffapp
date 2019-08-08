class GuidePage < BasePage
  set_url '/guide'

  section :content, '#content' do
    element :guide_header, 'h1', text: 'See the guides'
  end
end
