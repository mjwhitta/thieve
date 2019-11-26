Gem::Specification.new do |s|
    s.add_development_dependency("rake", "~> 13.0", ">= 13.0.0")
    s.add_runtime_dependency("hilighter", "~> 1.5", ">= 1.5.1")
    s.add_runtime_dependency("scoobydoo", "~> 1.0", ">= 1.0.1")
    s.authors = ["Miles Whittaker"]
    s.date = Time.new.strftime("%Y-%m-%d")
    s.description = [
        "This ruby gem searches through provided directories,",
        "looking for private/public keys and certs. Then extracts,",
        "fingerprints, and attempts to match keys with certs."
    ].join(" ")
    s.email = "mj@whitta.dev"
    s.executables = Dir.chdir("bin") do
        Dir["*"]
    end
    s.files = Dir["lib/**/*.rb"]
    s.homepage = "https://gitlab.com/mjwhitta/thieve"
    s.license = "GPL-3.0"
    s.metadata = {"source_code_uri" => s.homepage}
    s.name = "thieve"
    s.summary = "Steal keys/certs"
    s.version = "0.3.8"
end
