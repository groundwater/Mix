class CLI
  
  USAGE = <<-eoh
Usage: mix COMMAND TARGET

Commands

  install        install and deploy an application bundle
  
Targets are shorthand Github repositories like jacobgroundwater/demo-app

eoh
  
  def self.start!
    command = ARGV[0]
    target  = ARGV[1]
    CLI.new command, target
  end
  
  def initialize(command,target)
    case command
    when 'clone'
      clone target
    when 'bootstrap'
      bootstrap target
    when 'start'
      start target
    when 'install'
      install target
    else
      puts "Unknown Command: #{command}"
      puts USAGE
    end
  end
  
  def pathify(target)
    "#{ENV['HOME']}/Documents/Mix/Github/#{target}"
  end
  
  def resolve(target)
    if /\//.match target
      "git@github.com:#{target}.git"
    end
  end
  
  def dependencies(target)
    dest = pathify target
    deps = File.read File.join(dest,'Envfile')
    out = {}
    deps.each_line do |line|
      split = line.split /\s*:\s*/
      lhs = split[0]
      rhs = split[1].strip!
      out[lhs] = rhs
    end
    out
  end
  
  def bootstrap(target)
    puts "Bootstrapping Target #{target}"
    dest = pathify target
    %w{install}.each do |line|
      puts "--> Running Task #{line}"
      out = `(cd #{dest} && cat Taskfile | grep ^#{line} | sed 's/^#{line}\\s*:\\s*//' | bash | sed 's/^/    /')`
    end
  end
  
  def start(target)
    dest = pathify target
    port = 9999
    system "(cd #{dest} && cat Procfile | head -n 1 | sed 's/.*:\\w*//' | PORT=#{port} bash)"
  end
  
  def install(target)
    clone target
    (dependencies target).each do |key,value|
      puts "Target #{target} Had Dependency #{key} --> #{value}"
      install value
    end
    bootstrap target
  end
  
  def clone(target)
    url = resolve target
    if url
      puts "Target Resolved to #{url}"
      dest = pathify target
      if File.directory? dest
        puts "Target Already Cloned to #{dest}"
      else
        puts "Installing Target to #{dest}"
        `mkdir -p #{dest}`
        `git clone #{url} #{dest} | sed 's/^/    /'`
      end
    else
      puts "Unable to resolve target #{target}"
    end
  end
  
end
