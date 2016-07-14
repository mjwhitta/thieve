require "hilighter"
require "io/wait"
require "json"
require "pathname"
require "scoobydoo"

class Thieve
    attr_accessor :loot

    def export_loot(dir)
        exported = Hash.new
        @loot.each do |type, keys|
            keys.each do |key|
                key.export(dir)
                exported[key.type] ||= Hash.new
                exported[key.type]["#{key.fingerprint}.#{key.ext}"] =
                    key.to_json
            end
        end
        File.open("#{dir}/loot.json", "w") do |f|
            f.write(JSON.pretty_generate(exported))
        end
    end

    def extract_from(file)
        start = false
        key = ""

        File.open(file).each do |line|
            if (line.include?("BEGIN"))
                start = true
            end

            if (start)
                key += line.unpack("C*").pack("U*").lstrip.rstrip
                if (key.end_with?("\\n\\"))
                    key = key[0..-4]
                end
                key += "\\n"
            end

            if (line.include?("END"))
                key.scan(/(-----BEGIN(.*)[^-]+-----END\2)/) do |m, t|
                    keydata = m.gsub(/\\+n/, "\n").chomp
                    type = t.gsub(/-----.*/, "").strip

                    @loot[type] ||= Array.new
                    begin
                        @loot[type].push(
                            Thieve::KeyInfo.new(file, type, keydata)
                        )
                    rescue Exception => e
                        if (@@hilight)
                            $stderr.puts file.to_s.light_blue
                            keydata.each_line do |line|
                                $stderr.puts line.strip.light_yellow
                            end
                            $stderr.puts e.message.white.on_red
                        else
                            $stderr.puts file
                            $stderr.puts keydata
                            $stderr.puts e.message
                        end
                        $stderr.puts
                    end
                end

                start = false
                key = ""
            end
        end
    end
    private :extract_from

    def find_matches
        return if (@loot["CERTIFICATE"].nil?)
        @loot["CERTIFICATE"].each do |cert|
            next if (cert.openssl.nil?)
            @loot.each do |type, keys|
                next if (type == "CERTIFICATE")
                keys.each do |key|
                    next if (key.openssl.nil?)
                    if (cert.openssl.check_private_key(key.openssl))
                        cert.match = "#{key.fingerprint}.#{key.ext}"
                        key.match = "#{cert.fingerprint}.#{cert.ext}"
                    end
                end
            end
        end
    end

    def self.hilight?
        @@hilight ||= false
        return @@hilight
    end

    def hilight_type(type)
        return type if (!@@hilight)
        return type.light_cyan
    end
    private :hilight_type

    def initialize(hilight = false)
        if (ScoobyDoo.where_are_you("gpg").nil?)
            raise Thieve::Error::ExecutableNotFound.new("gpg")
        end

        @@hilight = hilight
        @loot = Hash.new
    end

    def steal_from(filename)
        file = Pathname.new(filename).expand_path

        if (file.directory?)
            files = Dir[File.join(file, "**", "*")].reject do |f|
                Pathname.new(f).directory? || Pathname.new(f).symlink?
            end

            files.each do |f|
                extract_from(Pathname.new(f).expand_path)
            end
        else
            extract_from(file)
        end

        return @loot
    end

    def summarize_loot
        ret = Array.new
        @loot.each do |type, keys|
            ret.push(hilight_type(type))
            keys.each do |key|
                ret.push("#{key.to_s}\n")
            end
        end

        return ret.join("\n")
    end
    private :summarize_loot

    def to_s
        return summarize_loot
    end
end

require "thieve/error"
require "thieve/key_info"
