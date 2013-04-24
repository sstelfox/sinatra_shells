
class Hash
  def deep_merge(other_hash)
    dup.deep_merge!(other_hash)
  end

  # Recusively merges hashes into each other. Any value that is not a Hash will
  # be overridden with the value in the other hash.
  #
  # @return [Hash] A copy of itself with the new hash merged in
  def deep_merge!(other)
    raise ArgumentError unless other.is_a?(Hash)

    other.each do |k, v|
      self[k] = (self[k].is_a?(Hash) && self[k].is_a?(Hash)) ? self[k].deep_merge(v) : v
    end

    self
  end
end

