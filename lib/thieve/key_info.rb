require "digest"
require "fileutils"
require "openssl"

class Thieve::KeyInfo
    # File extension to use when exporting
    attr_reader :ext

    # File that the key was found in
    attr_reader :file

    # The fingerprint
    attr_reader :fingerprint

    # The actual key
    attr_reader :key

    # The matching cert/key
    attr_accessor :match

    # The OpenSSL object
    attr_reader :openssl

    # Type of key/cert
    attr_reader :type

    def colorize_file(file = @file)
        return file if (!@colorize)
        return file.to_s.light_blue
    end
    private :colorize_file

    def colorize_key(key = @key)
        return key if (!@colorize)
        return key.split("\n").map do |line|
            line.light_white
        end.join("\n")
    end
    private :colorize_key

    def colorize_match(match = @match)
        return "" if (match.nil?)
        return "Matches #{match}" if (!@colorize)
        return [
            "Matches".light_blue,
            match.light_green
        ].join(" ")
    end
    private :colorize_match

    def export(directory)
        FileUtils.mkdir_p(directory)
        File.open("#{directory}/#{@fingerprint}.#{@ext}", "w") do |f|
            f.write(@key)
        end
    end

    def initialize(file, type, key, colorize)
        @colorize = colorize
        @ext = type.gsub(/ +/, ".").downcase
        @file = file
        @key = key
        @match = nil
        @type = type

        case @type
        when "CERTIFICATE"
            @openssl = OpenSSL::X509::Certificate.new(@key)
            @fingerprint = OpenSSL::Digest::SHA1.hexdigest(
                @openssl.to_der
            ).to_s
        when "CERTIFICATE REQUEST"
            @openssl = OpenSSL::X509::Request.new(@key)
            @fingerprint = OpenSSL::Digest::SHA1.hexdigest(
                @openssl.to_der
            ).to_s
        when "DH PARAMETERS"
            @openssl = OpenSSL::PKey::DH.new(@key)
            @fingerprint = OpenSSL::Digest::SHA1.hexdigest(
                @openssl.public_key.to_der
            ).to_s
        when "DH PRIVATE KEY"
            @openssl = OpenSSL::PKey::DH.new(@key)
            @fingerprint = OpenSSL::Digest::SHA1.hexdigest(
                @openssl.public_key.to_der
            ).to_s
        when "DSA PRIVATE KEY"
            @openssl = OpenSSL::PKey::DSA.new(@key)
            @fingerprint = OpenSSL::Digest::SHA1.hexdigest(
                @openssl.public_key.to_der
            ).to_s
        when "EC PARAMETERS"
            @openssl = OpenSSL::PKey::EC.new(@key)
            @fingerprint = OpenSSL::Digest::SHA1.hexdigest(
                @openssl.public_key.to_der
            ).to_s
        when "EC PRIVATE KEY"
            @openssl = OpenSSL::PKey::EC.new(@key)
            @fingerprint = OpenSSL::Digest::SHA1.hexdigest(
                @openssl.public_key.to_der
            ).to_s
        when "PGP PRIVATE KEY BLOCK"
            command = "gpg --with-fingerprint << EOF\n#{@key}\nEOF"
            %x(#{command}).each_line do |line|
                line.match(/Key fingerprint = (.*)/) do |m|
                    @fingerprint = m[1].gsub(" ", "").downcase
                end
            end
            @openssl = nil
        when "PGP PUBLIC KEY BLOCK"
            command = "gpg --with-fingerprint << EOF\n#{@key}\nEOF"
            %x(#{command}).each_line do |line|
                line.match(/Key fingerprint = (.*)/) do |m|
                    @fingerprint = m[1].gsub(" ", "").downcase
                end
            end
            @openssl = nil
        when "PRIVATE KEY"
            @openssl = OpenSSL::PKey::RSA.new(@key)
            @fingerprint = OpenSSL::Digest::SHA1.hexdigest(
                @openssl.public_key.to_der
            ).to_s
        when "PUBLIC KEY"
            @openssl = OpenSSL::PKey::RSA.new(@key)
            @fingerprint = OpenSSL::Digest::SHA1.hexdigest(
                @openssl.public_key.to_der
            ).to_s
        when "RSA PRIVATE KEY"
            @openssl = OpenSSL::PKey::RSA.new(@key)
            @fingerprint = OpenSSL::Digest::SHA1.hexdigest(
                @openssl.public_key.to_der
            ).to_s
        when "X509 CRL"
            @openssl = OpenSSL::X509::CRL.new(@key)
            @fingerprint = OpenSSL::Digest::SHA1.new(
                @openssl.to_der
            ).to_s
        else
            @ext = "unknown"
            @fingerprint = Digest::SHA256.hexdigest(@file.to_s + @key)
            @openssl = nil
        end
    end

    def to_json
        return {
            "file" => file,
            "fingerprint" => fingerprint,
            "key" => key,
            "match" => match || "",
            "type" => type
        }
    end

    def to_s
        ret = Array.new
        ret.push(colorize_file)
        ret.push(colorize_key)
        ret.push(colorize_match) if (@match)
        return ret.join("\n")
    end
end
