require "fileutils"
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

        FileUtils.mkdir_p(dir)
        File.open("#{dir}/loot.json", "w") do |f|
            f.write(JSON.pretty_generate(exported))
        end
    end

    def extract_from(file)
        start = false
        key = ""

        File.open(file).each do |line|
            start = true if (line.include?("BEGIN"))

            # Don't include newlines for now
            key += line.unpack("C*").pack("U*").strip if (start)

            if (line.include?("END"))
                # Remove " + " or ' + '
                key.gsub!(%r{["'] *\+ *["']}, "")

                # Remove bad characters
                key.gsub!(%r{[^-A-Za-z0-9+/= ]+}, "")

                # Find base64 key (accept spaces as we'll remove those
                # later)
                key_regex = [
                    "(",
                    "-----BEGIN ([A-Za-z0-9 ]+)-----",
                    "([A-Za-z0-9+/= ]+)",
                    "-----END \\2-----",
                    ")"
                ].join

                # Scan for valid key
                key.scan(%r{#{key_regex}}) do |m, type, k|
                    # Remove spaces from key
                    k.gsub!(/ +/, "")

                    # Format the keydata
                    keydata = k.scan(/.{,64}/).keep_if do |l|
                        !l.empty?
                    end
                    keydata.insert(0, "-----BEGIN #{type}-----")
                    keydata.push("-----END #{type}-----")

                    @loot[type] ||= Array.new
                    begin
                        @loot[type].push(
                            Thieve::KeyInfo.new(
                                file,
                                type,
                                keydata.join("\n")
                            )
                        )
                    rescue Exception => e
                        if (@@hilight)
                            $stderr.puts file.to_s.light_blue
                            keydata.each do |l|
                                $stderr.puts l.light_yellow
                            end
                            $stderr.puts e.message.white.on_red
                        else
                            $stderr.puts file
                            $stderr.puts keydata.join("\n")
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
        @loot["CERTIFICATE"].each do |c|
            next if (c.openssl.nil?)
            @loot.each do |type, keys|
                next if (type == "CERTIFICATE")
                keys.each do |k|
                    next if (k.openssl.nil?)
                    begin
                        if (c.openssl.check_private_key(k.openssl))
                            c.match = "#{k.fingerprint}.#{k.ext}"
                            k.match = "#{c.fingerprint}.#{c.ext}"
                        end
                    rescue
                        # Do nothing. Private key is needed.
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

    def steal_from(filename, ignores = Array.new)
        file = Pathname.new(filename).expand_path

        skip = ignores.any? do |ignore|
            file.to_s.match(%r{#{ignore}})
        end
        return @loot if (skip)

        if (file.directory?)
            files = Dir[File.join(file, "**", "*")].reject do |f|
                Pathname.new(f).directory? || Pathname.new(f).symlink?
            end

            files.each do |f|
                skip = ignores.any? do |ignore|
                    f.to_s.match(%r{#{ignore}})
                end
                next if (skip)

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
