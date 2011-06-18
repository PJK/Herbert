module Herbert
  module Utils
    # Assert v<major>.<minor>etc.. tags
    def self.version
      version = `git describe --long`.strip
      version[0] = '' if version[0] == 'v'
      version
    end
  end
end