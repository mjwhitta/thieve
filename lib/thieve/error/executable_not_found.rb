class Thieve::Error::ExecutableNotFound < Thieve::Error
    def initialize(exe)
        super("Please install #{exe}")
    end
end
