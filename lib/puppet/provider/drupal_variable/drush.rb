Puppet::Type.type(:drupal_variable).provide(:drush) do
  desc "Manage Drupal variables via Drush"

  commands :drush => 'drush'

  def self.instances
    vars = []
    begin
      drush('site-alias').reject{|s| s.start_with? '@' }.collect{|s| s.chomp }.each do |site|
        Puppet.debug "Loading variables for #{site}"
        # This is SHITTY! But the json exporter is broke
        drush('variable-get', '-l', site).each do |line|
          if match = line.match(/^(\w+): (\d+|".+")$/) # These regexes just get rid of complex values.
            name  = "#{site}::#{match[1]}"
            value = match[2].gsub(/^\"|\"$/, '')
            vars << new(:ensure => :present, :name => name, :value => value)
            #vars << new(:ensure => :present, :site => site, :name => match[1], :value => value)
          end
        end
      end
    rescue Puppet::ExecutionFailure => e
      Puppet.debug "Drupal variables: #{e.message}"
    end
    vars
  end

  def self.prefetch(resources)
    vars = instances
    Puppet.debug vars.inspect
    resources.keys.each do |name|
      if provider = vars.find{ |v| v.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    Puppet.debug "    Site: #{resource[:site]}"
    Puppet.debug "    Name: #{resource[:name]}"
    Puppet.debug @property_hash.inspect
    @property_hash[:ensure] == :present
  end

  def create
    begin
      drush('variable-set', '--exact', '-l', resource[:site], resource[:variable], resource[:value])
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
    drush('variable-set', '--exact', '-l', resource[:site], resource[:variable], should)
    @property_hash[:value] = should
  end

end
