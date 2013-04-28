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
    when 'install'
      install target
    else
      puts "Unknown Command: #{command}"
      puts USAGE
    end
  end
  
  def resolve(target)
    if /\//.match target
      "git@github.com:#{target}.git"
    end
  end
  
  def install(target)
    url = resolve target
    if url
      puts "Target Resolved to #{url}"
      dest = "~/Documents/Mix/Github/#{target}"
      puts "Installing Target to #{dest}"
      `mkdir -p #{dest}`
      `git clone #{url} #{dest}`
    else
      puts "Unable to resolve target #{target}"
    end
  end
  
end
