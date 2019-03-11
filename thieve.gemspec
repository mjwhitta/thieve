Gem::Specification.new do |s|
    s.name = "thieve"
    s.version = "0.3.6"
    s.date = Time.new.strftime("%Y-%m-%d")
    s.summary = "Steal keys/certs"
    s.description =
        "This ruby gem searches through provided directories, " \
        "looking for private/public keys and certs. Then extracts, " \
        "fingerprints, and attempts to match keys with certs."
    s.authors = [ "Miles Whittaker" ]
    s.email = "mjwhitta@gmail.com"
    s.executables = Dir.chdir("bin") do
        Dir["*"]
    end
    s.files = Dir["lib/**/*.rb"]
    s.homepage = "https://gitlab.com/mjwhitta/thieve"
    s.license = "GPL-3.0"
    s.add_development_dependency("rake", "~> 12.3", ">= 12.3.2")
    s.add_runtime_dependency("hilighter", "~> 1.1", ">= 1.2.3")
    s.add_runtime_dependency("scoobydoo", "~> 1.0", ">= 1.0.0")
end
