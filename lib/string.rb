# Modify String class to allow for rsplit and word wrap
class String
    def rsplit(pattern)
        ret = rpartition(pattern)
        ret.delete_at(1)
        return ret
    end

    def word_wrap(width = 80)
        return scan(/\S.{0,#{width}}\S(?=\s|$)|\S+/).join("\n")
    end
end
