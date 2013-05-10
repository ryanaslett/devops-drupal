require 'pathname'
require 'uri'

Puppet::Type.newtype(:drupal_variable) do
  desc "Manages a Drupal variable"
  ensurable

  newparam(:name, :namevar => true) do
    desc 'Name of the variable'
    validate do |value|
      unless value =~ /^\S+$/
        raise ArgumentError, "Name must not contain whitespace: #{value}"
      end
    end
  end

  newproperty(:value) do
    desc "The value this variable should be set to"
  end

end
