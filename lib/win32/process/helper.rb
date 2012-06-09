class String
  # Convert a regular string to a wide character string. This does not
  # modify the receiver.
  def to_wide_string
    (self + 0.chr).encode('UTF-16LE')
  end

  # Convert a regular string to a wide character string. This modifies
  # the receiver.
  def to_wide_string!
    replace((self + 0.chr).encode('UTF-16LE'))
  end
end
