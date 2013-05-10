Puppet::Type.type(:drupal_module).provide(:drush) do
  desc "Manage Drupal modules via Drush"

  commands :drush => 'drush'

  def self.instances
    mods = []
    begin
      drush('pm-list').each do |line|
        if match = line.match(/(\w+)\W+(\w+) \((\w+)\)\W+Module\W+(Enabled|Disabled|Not installed)\W+(\S+)/)
          mods << new(:ensure  => statussymbol(match[4]),
                      :package => match[1],
                      :label   => match[2],
                      :name    => match[3],
                      :version => match[5])
        end
      end
    rescue Puppet::ExecutionFailure => e
      Puppet.debug "Drupal modules: #{e.message}"
    end
    mods
  end

  def self.prefetch(resources)
    mods = instances
    resources.keys.each do |name|
      if provider = mods.find{ |m| m.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    [:present, :enabled].include? @property_hash[:ensure]
  end

  def create
    if drush('pm-info', resource[:name]).include? 'was not found'
      drush('pm-download', resource[:name], '--yes')
    end

    drush('pm-enable', resource[:name], '--yes')
    @property_hash[:ensure] = :present
  end

  def destroy
    drush('pm-disable', resource[:name], '--yes')
    @property_hash[:ensure] = :disabled
  end

  def uninstall
    drush('pm-disable', resource[:name], '--yes') if @property_hash[:ensure] != :disabled
    drush('pm-uninstall', resource[:name], '--yes')
    @property_hash[:ensure] = :uninstalled
  end

  def version
    @property_hash[:version]
  end

  def version=(should)
    drush('pm-download', "#{resource[:name]}-#{should}", '--yes')
    drush('pm-enable', resource[:name], '--yes')
    @property_hash[:version] = should
  end

  private
  def self.statussymbol(status)
    return :uninstalled if status == 'Not installed'
    return status.downcase.to_sym
  end
end
