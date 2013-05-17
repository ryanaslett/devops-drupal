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
            Puppet.debug "drups: Creating #{name}:#{value}"
            vars << new(:ensure => :present, :name => name, :value => value)

            # If I add new resources with each var set like this, I get duplicate resource warnings
            #vars << new(:ensure => :present, :site => site, :name => match[1], :value => value)

            # This leads to Could not run: No resource and no name in property hash in drush instance
            #vars << new(:ensure => :present, :title => name, :value => value)
          end
        end
      end
    rescue Puppet::ExecutionFailure => e
      Puppet.debug "Drupal variables: #{e.message}"
    end
    # This @property_hash dump looks as expected, unless the title_patterns bit should have parsed :name already
    # debug: {:value=>"1", :ensure=>:present, :name=>"my.site.com::user_register"}
    Puppet.debug vars[0].inspect
    vars
  end

  def self.prefetch(resources)
    # This is never run during puppet resource
    Puppet.debug "drups: Called self.prefetch"
    vars = instances
    Puppet.debug vars.inspect
    resources.keys.each do |name|
      Puppet.debug "#{name}"
      if provider = vars.find{ |v| v.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    # These get parsed into the proper values only when a property is being set
    # And when they're set, they don't match the name in the @property_hash, so the resource
    # is never constructed properly.
    Puppet.debug "drups:    Site: #{resource[:site]}"
    Puppet.debug "drups:    Name: #{resource[:name]}"

    # This @property_hash dump looks as expected when no value is provided
    # e.g. `puppet resource drupal_variable my.site.com::user_register`
    # debug: {:value=>"1", :ensure=>:present, :name=>"my.site.com::user_register"}
    #
    # However, if I specify a value, like `puppet resource drupal_variable my.site.com::user_register value=1`
    # I get an empty hash, {}.
    Puppet.debug "drups: #{@property_hash.inspect}"
    Puppet.debug "drups: exists?: #{@property_hash[:ensure] == :present}"
    @property_hash[:ensure] == :present
  end

  def create
    # however, any time I call puppet resource drupal_variable site:name value=something, create is called
    # rather than the variable= method. Dumping the hash at this point gets me just {} since it's a new object
    begin
      drush('variable-set', '--exact', '-l', resource[:site], resource[:name], resource[:value])
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
    @property_hash[:value] || :absent
  end

  def value=(should)
    drush('variable-set', '--exact', '-l', resource[:site], resource[:name], should)
    @property_hash[:value] = should
  end

end
