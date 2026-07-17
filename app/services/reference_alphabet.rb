# Single source of truth for the characters allowed in generated reference
# numbers. Excludes characters people frequently misread or mistype when copying
# a reference by hand: I, O, S, 0, 1, 2, 5.
module ReferenceAlphabet
  EXCLUDED = ['I', 'O', 'S', '0', '1', '2', '5'].freeze

  # 23 letters + 6 digits = 29 characters.
  SAFE_CHARS = ((('A'..'Z').to_a - EXCLUDED) + (('0'..'9').to_a - EXCLUDED)).freeze
end
