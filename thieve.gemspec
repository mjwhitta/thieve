Gem::Specification.new do |s|
    s.name = "thieve"
    s.version = "0.1.5"
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
    s.homepage = "https://mjwhitta.github.io/thieve"
    s.license = "GPL-3.0"
    s.add_development_dependency("rake", "~> 10.5", ">= 10.5.0")
    s.add_runtime_dependency("colorize", "~> 0.7", ">= 0.7.7")
    s.add_runtime_dependency("scoobydoo", "~> 0.1", ">= 0.1.3")
end
