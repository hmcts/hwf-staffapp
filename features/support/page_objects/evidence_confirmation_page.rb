class EvidenceConfirmationPage < BasePage
  set_url_matcher %r{/evidence/[0-9]+/confirmation}

  section :content, '#content' do
  end
end
