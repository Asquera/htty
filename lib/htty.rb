# Loads constants defined within HTTY.

# Contains the implementation of _htty_.
module HTTY

  # The version of this release of _htty_.
  VERSION = File.read("#{File.dirname __FILE__}/../VERSION").chomp

  def self.requests_util
    @requests_util ||= HTTY::RequestsUtil
  end
  
  def self.requests_util=(util)
    @requests_util = util
  end
end

Dir.glob "#{File.dirname __FILE__}/htty/*.rb" do |f|
  require File.expand_path("#{File.dirname __FILE__}/htty/" +
                           File.basename(f, '.rb'))
end
