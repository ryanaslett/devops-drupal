require 'pathname'
require 'uri'

Puppet::Type.newtype(:drupal_variable) do
  desc "Manages a Drupal variable"
  ensurable

#   # I don't think this can work because :site should default to value if not provided.
#   def self.title_patterns
#     [
#       [ /^((\.|\w)+)(::\w+)?$/, [ [ :site ] ] ],
#       [ /^(\.|\w)+::(\w+)$/,    [ [ :variable ] ] ]
#     ]
#   end

  newparam(:name, :namevar => true) do
    desc 'Name of the variable'
    validate do |value|
      unless value =~ /^(\.|\w)+(::\w+)?$/
        raise ArgumentError, "Name must not contain whitespace: #{value}"
      end
    end
    munge do |value|
      if value.include? '::'
        resource[:site], resource[:variable] = value.split('::')
      else
        resource[:site]     = 'default'
        resource[:variable] = value
      end
      "#{resource[:site]}::#{resource[:variable]}"
    end
  end

  newparam(:site) do
    desc "Site name. Set by using a name in the format 'site::variable'"
  end

  newparam(:variable) do
    desc "Variable name. Set by using a name in the format 'site::variable'"
  end

  newproperty(:value) do
    desc "The value this variable should be set to"
  end

end
