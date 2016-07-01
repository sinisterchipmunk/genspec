module GenSpec
  class Version
    MAJOR = 0
    MINOR = 3
    PATCH = 0
    RELEASE = nil
    
    STRING = (RELEASE ? [MAJOR, MINOR, PATCH, RELEASE] : [MAJOR, MINOR, PATCH]).join('.')
  end
  
  VERSION = Version::STRING
end
