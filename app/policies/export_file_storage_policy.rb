class ExportFileStoragePolicy < BasePolicy
  def download?
    @record.user == @user
  end
end
