class Levenshtein
  def self.encoding_of(string)
    if RUBY_VERSION[0, 3] == "1.9"
      string.encoding.to_s
    end
  end

  def self.compute(str1, str2)
    unpack_rule = if encoding_of(str1) =~ /^U/i
                    'U*'
                  else
                    'C*'
                  end

    s = str1.unpack(unpack_rule)
    t = str2.unpack(unpack_rule)
    n = s.length
    m = t.length

    return m if n.zero?
    return n if m.zero?

    d = (0..m).to_a
    x = nil
    s_i = nil

    (0...n).each do |i|
      e = i + 1
      s_i = s.at(i)
      (0...m).each do |j|
        cost = s_i == t.at(j) ? 0 : 1
        x = [
          d.at(j + 1) + 1, # insertion
          e + 1,         # deletion
          d.at(j) + cost # substitution
        ].min
        d[j] = e
        e = x
      end
      d[m] = x
    end

    x
  end
end
