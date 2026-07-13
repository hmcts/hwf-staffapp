class ReferenceGenerator

  SUFFIX_LENGTH = 6

  def initialize(application)
    @application = application
  end

  def attributes
    { reference: reference }
  end

  private

  def reference_prefix
    "PA#{Time.zone.now.strftime('%y')}-"
  end

  # A random confusable-free reference, unique against the applications table.
  # Uniqueness is a single indexed lookup (exists? -> SELECT 1 ... LIMIT 1), so
  # this stays fast regardless of how many references already exist (unlike
  # scanning every reference for the year). unscoped is used so the check also
  # sees soft-deleted rows, matching the unique index which covers every row.
  def reference
    begin
      candidate = "#{reference_prefix}#{random_suffix}"
    end while Application.unscoped.exists?(reference: candidate)

    candidate
  end

  def random_suffix
    chars = ReferenceAlphabet::SAFE_CHARS
    Array.new(SUFFIX_LENGTH) { chars[SecureRandom.random_number(chars.length)] }.join
  end
end
