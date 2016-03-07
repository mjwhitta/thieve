Gem::Specification.new do |s|
    s.name = "thieve"
    s.version = "0.1.0"
    s.date = Time.new.strftime("%Y-%m-%d")
    s.summary = "Extract, fingerprint, and match-up keys and/or certs"
    s.description =
        "This ruby gem will extract, fingerprint, and match-up " \
        "keys and/or certs from source code trees."
    s.authors = [ "Miles Whittaker" ]
    s.email = "mjwhitta@gmail.com"
    s.executables = Dir.chdir("bin") do
        Dir["*"]
    end
    s.files = Dir["lib/**/*.rb"]
    s.homepage = "https://mjwhitta.github.io/thieve"
    s.license = "GPL-3.0"
    s.add_runtime_dependency("colorize", "~> 0.7", ">= 0.7.7")
end
