require 'pathname'
require 'uri'

Puppet::Type.newtype(:drupal_variable) do
  desc "Manages a Drupal variable"
  ensurable

  def self.title_patterns
    [
      [ /^([\.|\w]+)::(\w+)$/, [ [ :site, lambda {|x| x} ], [ :name, lambda {|x| x} ] ] ],
      [ /^(\w+)$/, [ [ :name, lambda {|x| x} ] ] ]
    ]
  end

#   newparam(:name, :namevar => true) do
#     desc 'Name of the variable'
#     validate do |value|
#       unless value =~ /^(\.|\w)+(::\w+)?$/
#         raise ArgumentError, "Name must not contain whitespace: #{value}"
#       end
#     end
#     munge do |value|
#       if value.include? '::'
#         resource[:site], resource[:variable] = value.split('::')
#       else
#         resource[:site]     = 'default'
#         resource[:variable] = value
#       end
#       "#{resource[:site]}::#{resource[:variable]}"
#     end
#   end

  newparam(:site, :namevar => true) do
    desc "Site name. Can be set by using a title in the format 'site::variable'"
    newvalues /^[\.|\w]+$/
    defaultto 'default'
  end

  newparam(:name, :namevar => true) do
    desc "Variable name. Can be set by using a title in the format 'site::variable'"
    newvalues /^[\.|\w]+(::\w+)?$/
  end

  newproperty(:value) do
    desc "The value this variable should be set to"
  end

end
