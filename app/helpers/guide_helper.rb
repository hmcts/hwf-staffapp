module GuideHelper

  def how_to_url
    'https://justiceuk.sharepoint.com/:w:/r/sites/knowledgecentral/_layouts/15/Doc.aspx?sourcedoc=%7B5D999F01-6E39-4EB6-8703-E3E4A0262580%7D&file=how-to-guide_wordversion.docx&action=default&mobileredirect=true'
  end

  def training_course_url
    'https://justiceuk.sharepoint.com/:w:/r/sites/knowledgecentral/_layouts/15/Doc.aspx?sourcedoc=%7BB3128FFC-3EF6-4648-B2BB-8A3D8A29E9BA%7D&file=Help%20with%20Fees%20My%20Learning%20LINK.docx&action=default&mobileredirect=true'
  end

  def key_control_checks_url
    'https://intranet.justice.gov.uk/my-work/soc-standard-operating-controls-self-assessment/key-control-check-sheets/cross-jurisdiction-kccs/'
  end

  def staff_guidance_url
    'https://justiceuk.sharepoint.com/:w:/r/sites/knowledgecentral/_layouts/15/Doc.aspx?sourcedoc=%7BDD4BE471-9B43-43D4-9E71-0FB28A9B41EE%7D&file=policy-guide%20_word%20version.docx&action=default&mobileredirect=true'
  end

  def old_process_application_url
    'https://intranet.justice.gov.uk/documents/2021/11/processing-a-help-with-fees-application.docx'
  end

  def new_process_application_url
    if Settings.dwp_api_enabled == true
      'https://justiceuk.sharepoint.com/:w:/r/sites/knowledgecentral/Shared%20Documents/Cross-Jurisdiction/Help%20with%20Fees/Job%20Cards/Processing%20a%20paper%20Help%20with%20Fees%20application.docx?d=w16e76ffee0614a44b9e095196dd137c3&csf=1&web=1&e=sgEdnc&isSPOFile=1'
    else
      'https://justiceuk.sharepoint.com/:w:/r/sites/knowledgecentral/_layouts/15/Doc.aspx?sourcedoc=%7BB62AF5DB-DF50-4415-A261-A4598E61B298%7D&file=Process%20a%20paper%20HWF%20application%20-%20Jobcard_word%20version.docx&action=default&mobileredirect=true'
    end
  end

  def new_online_process_application_url
    if Settings.dwp_api_enabled == true
      'https://justiceuk.sharepoint.com/:w:/r/sites/knowledgecentral/Shared%20Documents/Cross-Jurisdiction/Help%20with%20Fees/Job%20Cards/Processing%20an%20Online%20Help%20with%20Fees%20application.docx?d=w560392691852483096baa52a0ae64955&csf=1&web=1&e=wB6vIK&isSPOFile=1'
    else
      'https://justiceuk.sharepoint.com/:w:/r/sites/knowledgecentral/_layouts/15/Doc.aspx?sourcedoc=%7B1ADE6338-5A41-4D11-8047-ACBB1A070C19%7D&file=Process%20an%20online%20HWF%20application%20-%20Jobcard_word%20version.docx&action=default&mobileredirect=true'
    end
  end

  def old_evidence_checks_url
    'https://intranet.justice.gov.uk/documents/2020/12/help-with-fees-processing-evidence-job-card.pdf'
  end

  def new_evidence_checks_url
    if Settings.dwp_api_enabled == true
      'https://justiceuk.sharepoint.com/:w:/r/sites/knowledgecentral/Shared%20Documents/Cross-Jurisdiction/Help%20with%20Fees/Job%20Cards/Processing%20manual%20evidence%20for%20a%20Help%20with%20Fees%20Application.docx?d=wb9f4849824cd4e73b4185a24d1dca202&csf=1&web=1&e=lExQ4P&isSPOFile=1'
    else
      'https://justiceuk.sharepoint.com/:w:/r/sites/knowledgecentral/_layouts/15/Doc.aspx?sourcedoc=%7B40446293-A8A9-4003-B09E-F228F727A441%7D&file=Processing%20HWF%20evidence-%20Jobcard_word%20version.docx&action=default&mobileredirect=true'
    end
  end

  def part_payment_url
    if Settings.dwp_api_enabled == true
      'https://justiceuk.sharepoint.com/:w:/r/sites/knowledgecentral/Shared%20Documents/Cross-Jurisdiction/Help%20with%20Fees/Job%20Cards/Processing%20a%20Help%20with%20Fees%20part%20payment.docx?d=w030275ccc48141329be20a8e9f0fe129&csf=1&web=1&e=96XSo9&isSPOFile=1'
    else
      'https://justiceuk.sharepoint.com/:w:/r/sites/knowledgecentral/_layouts/15/Doc.aspx?sourcedoc=%7BA5D5C042-C211-45A6-B1C5-22275AC6E0C5%7D&file=Processing%20a%20part-payment%20-%20Jobcard_word%20version.docx&action=default&mobileredirect=true'
    end
  end

  def fraud_awareness_url
    'https://justiceuk.sharepoint.com/:w:/r/sites/knowledgecentral/_layouts/15/doc2.aspx?sourcedoc=%7BAB40BF95-B160-4B92-8A5C-337F977ED643%7D&file=updatedMay2026_Fraud-awareness-word%20version_Alessandra%20Valle%20Met.docx&action=default&mobileredirect=true'
  end

  def rrds_url
    'https://justiceuk.sharepoint.com/:w:/r/sites/knowledgecentral/_layouts/15/Doc.aspx?sourcedoc=%7B34D2BF32-AEB1-41D7-BF74-9C76A6E8042B%7D&file=Record%20Retention%20and%20Dispotion%20Schedules%20RRDS%20LINK.docx&action=default&mobileredirect=true'
  end

  def datashare_url
    'https://justiceuk.sharepoint.com/:w:/r/sites/knowledgecentral/_layouts/15/Doc.aspx?sourcedoc=%7BB23D0CC3-7CF7-47B8-A12A-B79AAA0146FC%7D&file=updated_23March2026_HMRC-datashare-step-by-st_Loren%20Barrow.docx'
  end

  def faq_url
    'https://justiceuk.sharepoint.com/sites/knowledgecentral/Shared%20Documents/Forms/AllItems.aspx' \
      '?id=%2Fsites%2Fknowledgecentral%2FShared%20Documents%2FCross%2DJurisdiction%2FHelp%20with' \
      '%20Fees%2FHWF%5FFAQ%20%5FOriginal%5FVersion1%2E0%5F28%2E10%2E2025%2Epdf' \
      '&parent=%2Fsites%2Fknowledgecentral%2FShared%20Documents%2FCross%2DJurisdiction%2FHelp%20with%20Fees'
  end

  def manager_guide_url
    'https://justiceuk.sharepoint.com/:w:/s/knowledgecentral/IQBseyY-O1RLQK0W_lW_Q_22AYp2C_S0XNmU0jwaZ8-OifQ?web=1'
  end

  def income_check_guidance_url
    if Settings.dwp_api_enabled == true
      'https://justiceuk.sharepoint.com/:w:/r/sites/knowledgecentral/_layouts/15/' \
        'Doc.aspx?sourcedoc=%7B28F4D6C2-FE0B-4E1C-AA11-' \
        '1FBAF3D3BB83%7D&file=Evidence%20Checking%20-Final%20Version' \
        '%2025.09.2026%20(003).docx&action=default&mobileredirect=true'
    else
      'https://justiceuk.sharepoint.com/sites/knowledgecentral/SitePages/Job-Cards.aspx?CT=1790263187017&OR=OWA-NT-Mail&CID=fb29972c-06fc-9665-0c18-62cef19df7c1&SI=NonSentItems&SLSync=Y'
    end
  end

  def benefit_check_guidance_url
    'https://justiceuk.sharepoint.com/:w:/r/sites/knowledgecentral/Shared%20Documents/Cross-Jurisdiction/Help%20with%20Fees/Job%20Cards/Evidence%20Checking%20-%20Benefits%20final%201.docx?d=w2654f399e92f46dba892d40a8ed34298&csf=1&web=1&e=MUGOhu'
  end

  def processing_paper_applications_job_card_url
    'https://justiceuk.sharepoint.com/:w:/r/sites/knowledgecentral/_layouts/15/Doc.aspx?sourcedoc=%7BB62AF5DB-DF50-4415-A261-A4598E61B298%7D&file=Process%20a%20paper%20HWF%20application%20-%20Jobcard_word%20version.docx&action=default&mobileredirect=true'
  end
end
