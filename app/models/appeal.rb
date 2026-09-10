# A staff review of benefit evidence received after a benefit application was
# processed as not eligible. An application can be reviewed only once
# (CHANGELOG.md).
class Appeal < ActiveRecord::Base
  belongs_to :application, optional: false
  belongs_to :completed_by, -> { with_deleted }, class_name: 'User', optional: false

  validates :application_id, uniqueness: true
end
