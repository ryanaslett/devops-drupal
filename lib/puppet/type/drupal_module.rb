require 'pathname'
require 'uri'

Puppet::Type.newtype(:drupal_module) do
  desc "Manages a Drupal module"

  ensurable do
    desc "The state the module should be in."
    defaultvalues

    newvalue(:enabled) do
      provider.create
    end

    newvalue(:disabled) do
      provider.destroy
    end

    newvalue(:uninstalled) do
      provider.uninstall
    end
  end

  newparam(:name, :namevar => true) do
    desc 'Name of the module'
    validate do |value|
      unless value =~ /^\S+$/
        raise ArgumentError, "Must not contain whitespace: #{value}"
      end
    end
  end

  newparam(:label) do
    desc 'Human readable name of the module'
  end

  newparam(:package) do
    desc 'Package the module belongs to'
    validate do |value|
      unless value =~ /^\S+$/
        raise ArgumentError, "Must not contain whitespace: #{value}"
      end
    end
  end

  newproperty(:version) do
    desc "The the version of the module"
  end

end
