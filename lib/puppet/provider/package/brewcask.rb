require "puppet/provider/package"

Puppet::Type.type(:package).provide :brewcask,
  :parent => Puppet::Provider::Package do

  confine  :operatingsystem => :darwin

  has_feature :versionable
  has_feature :install_options

  # no caching, thank you
  def self.instances
    []
  end

  def self.home
    "#{Facter[:boxen_home].value}/homebrew"
  end

  def self.run(*cmds)
    puts "run: entering"
    command = ["sudo", "-E", "-u", Facter[:luser].value, "#{home}/bin/brew", "cask", *cmds].flatten.join(' ')
    puts "running command: #{command}"
    output = `#{command}`
    unless $? == 0
      fail "Failed running #{command}"
    end

    output
  end

  def self.current(name)
    puts "current: entering"
    caskdir = Pathname.new "#{home}/Caskroom/#{name}"
    puts "caskdir: #{caskdir}"
    caskdir.directory? && caskdir.children.size >= 1 && caskdir.children.sort.last.to_s
  end

  def query
    puts "query: entering"
    return unless version = self.class.current(resource[:name])
    { :ensure => version, :name => resource[:name] }
  end

  def install
    puts "install: entering"
    run "install", resource[:name], *install_options
  end

  def uninstall
    puts "install: entering"
    run  "uninstall", resource[:name]
  end

  def install_options
    puts "install_options: entering"
    Array(resource[:install_options]).flatten.compact
  end

  def run(*cmds)
    puts "run2: entering"
    self.class.run(*cmds)
  end
end
