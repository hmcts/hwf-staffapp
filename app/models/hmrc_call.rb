class HmrcCall < ApplicationRecord
  belongs_to :hmrc_check, optional: false

  serialize :call_params, coder: YAML
end
