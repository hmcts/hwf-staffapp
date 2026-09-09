# A staff review of benefit evidence received after a benefit application was
# processed as not eligible. An application can be reviewed more than once;
# the latest appeal is the source of truth (CHANGELOG.md).
class Appeal < ActiveRecord::Base
  belongs_to :application, optional: false
  belongs_to :completed_by, -> { with_deleted }, class_name: 'User', optional: false
end
