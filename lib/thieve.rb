require "base64"
require "fileutils"
require "hilighter"
require "io/wait"
require "json"
require "pathname"
require "scoobydoo"

class Thieve
    attr_accessor :loot

    def display_exception(e, file, keydata)
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
    private :display_exception

    def export_loot(dir, priv_only = @private)
        exported = Hash.new
        @loot.each do |type, keys|
            next if (priv_only && !type.match(/CERTIFICATE|PRIVATE/))

            keys.each do |key|
                if (priv_only && type.match(/CERTIFICATE/))
                    next if (key.match.nil?)
                end

                key.export(dir)
                exported[type] ||= Hash.new
                exported[type]["#{key.fingerprint}.#{key.ext}"] =
                    key.to_json
            end
        end

        FileUtils.mkdir_p(dir)
        File.open("#{dir}/loot.json", "w") do |f|
            f.write(JSON.pretty_generate(exported))
        end
    end

    def extract_from(file)
        footer = ""
        headers = Array.new
        key = ""
        start = false

        File.open(file).each do |line|
            if (line.include?("-----BEGIN"))
                footer = ""
                headers.clear
                key = ""
                start = true
            end

            if (start)
                # Don't include newlines for now
                line = line.unpack("C*").pack("U*").strip

                case line
                when /^=[^=]+$/
                    footer = line
                when /^.+:.+$/
                    headers.push(line)
                else
                    key += line
                end
            end

            if (line.include?("-----END"))
                # Remove " + " or ' + '
                key.gsub!(%r{["'] *\+ *["']?|["']? *\+ *["']}, "")

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
                    # Ignore breakpad microdumps
                    next if (type.match(/BREAKPAD MICRODUMP/))

                    # Remove spaces from key
                    k.gsub!(/ +/, "")

                    # Format the keydata
                    keydata = k.scan(/.{,64}/).keep_if do |l|
                        !l.empty?
                    end

                    # Prepend headers
                    if (headers.any?)
                        keydata.insert(0, "")
                        keydata.insert(0, headers.join("\n"))
                    end

                    # Append footer
                    keydata.push(footer) if (!footer.empty?)

                    # Prepend BEGIN
                    keydata.insert(0, "-----BEGIN #{type}-----")

                    # Append END
                    keydata.push("-----END #{type}-----")

                    begin
                        # Ensure key is base64 data
                        Base64.strict_decode64(k)

                        @loot[type] ||= Array.new
                        @loot[type].push(
                            Thieve::KeyInfo.new(
                                file,
                                type,
                                keydata.join("\n")
                            )
                        )
                    rescue Exception => e
                        display_exception(e, file, keydata)
                    end
                end

                start = false
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

        if (ScoobyDoo.where_are_you("grep").nil?)
            raise Thieve::Error::ExecutableNotFound.new("grep")
        end

        @@hilight = hilight
        @loot = Hash.new
        @private = false
    end

    def only_private(priv)
        @private = priv
    end

    def steal_from(filename, ignores = Array.new, binaries = false)
        cmd = ["\\grep"]
        cmd.push("-a") if (binaries)

        ignores.each do |ignore|
            cmd.push("--exclude-dir \"#{ignore}\"")
            cmd.push("--exclude \"#{ignore}\"")
        end

        cmd.push("-I") if (!binaries)
        cmd.push("-lrs -- \"-----BEGIN\" #{filename}")

        %x(#{cmd.join(" ")}).each_line do |f|
            file = Pathname.new(f.strip).expand_path

            skip = ignores.any? do |ignore|
                File.fnmatch(ignore, file.to_s)
            end
            next if (skip)

            extract_from(file)
        end

        return @loot
    end

    def summarize_loot(priv_only = @private)
        ret = Array.new
        @loot.each do |type, keys|
            next if (priv_only && !type.match(/CERTIFICATE|PRIVATE/))

            ret.push(hilight_type(type))
            keys.each do |key|
                if (priv_only && type.match(/CERTIFICATE/))
                    next if (key.match.nil?)
                end

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
