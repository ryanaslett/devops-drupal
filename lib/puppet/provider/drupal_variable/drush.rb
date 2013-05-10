Puppet::Type.type(:drupal_variable).provide(:drush) do
  desc "Manage Drupal variables via Drush"

  commands :drush => 'drush'

  def self.instances
    vars = []
    begin
      # This is SHITTY! But the json exporter is broke
      drush('variable-get').each do |line|
        if match = line.match(/^(\w+): (\d+|".+")$/)
          vars << new(:ensure => :present, :name => match[1], :value => match[2].gsub(/^\"|\"$/, '') )
        end
      end
    rescue Puppet::ExecutionFailure => e
      Puppet.debug "Drupal variables: #{e.message}"
    end
    vars
  end

  def self.prefetch(resources)
    vars = instances
    resources.keys.each do |name|
      if provider = vars.find{ |v| v.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    begin
      drush('variable-set', resource[:name], resource[:value])
      @property_hash[:ensure] = :present
    rescue Puppet::ExecutionFailure => e
      raise Puppet::Error, "Couldn't set #{resource[:name]} to #{resource[:value]} (#{e.message})"
    end
  end

  def destroy
    begin
      drush('variable-delete', '--exact', '--yes', resource[:name])
      @property_hash[:ensure] = :absent
    rescue Puppet::ExecutionFailure => e
      raise Puppet::Error, "Couldn't delete #{resource[:name]} (#{e.message})"
    end
  end

  def value
    @property_hash[:value]
  end

  def value=(should)
    drush('variable-set', resource[:name], should)
    @property_hash[:value] = should
  end
end
