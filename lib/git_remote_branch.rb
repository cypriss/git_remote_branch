require 'rubygems'
require 'colored'

grb_app_root = File.expand_path( File.dirname(__FILE__) + '/..' )
$LOAD_PATH.unshift( grb_app_root + '/lib' )
require 'param_reader'
require 'version'

module GitRemoteBranch
  class InvalidBranchError < RuntimeError; end

  COMMANDS = {
    :create     => {
      :description => 'create a new remote branch and track it locally',
      :aliases  => %w{create new},
      :commands => [
        '"git push #{origin} #{current_branch}:refs/heads/#{branch_name}"',
        '"git fetch #{origin}"',
        '"git branch --track #{branch_name} #{origin}/#{branch_name}"',
        '"git checkout #{branch_name}"'
      ]
    },

    :rename     => {
      :description => 'rename a remote branch and its local tracking branch',
      :aliases  => %w{rename rn mv move},
      :commands => [
        '"git push #{origin} #{current_branch}:refs/heads/#{branch_name}"',
        '"git fetch #{origin}"',
        '"git branch --track #{branch_name} #{origin}/#{branch_name}"',
        '"git checkout #{branch_name}"',
        '"git push #{origin} :refs/heads/#{current_branch}"',
        '"git branch -d #{current_branch}"',
      ]
    },

    :delete     => {
      :description => 'delete a local and a remote branch',
      :aliases  => %w{delete destroy kill remove rm},
      :commands => [
        '"git push #{origin} :refs/heads/#{branch_name}"',
        '"git checkout master" if current_branch == branch_name',
        '"git branch -d #{branch_name}"'
      ]
    },

    :track      => {
      :description => 'track an existing remote branch',
      :aliases  => %w{track follow grab fetch},
      :commands => [
        '"git fetch #{origin}"',
        '"git checkout master" if current_branch == branch_name',
        '"git branch --track #{branch_name} #{origin}/#{branch_name}"'
      ]
    }
  }

  def get_welcome
    "git_remote_branch version #{VERSION}\n\n"
  end

  def get_usage
    return <<-HELP
  Usage:

  grb create branch_name [origin_server]

  grb delete branch_name [origin_server]

  grb rename branch_name [origin_server]

  grb track branch_name [origin_server]

  If origin_server is not specified, the name 'origin' is assumed (git's default)
  
  The explain meta-command: you can also prepend any command with the keyword 'explain'. Instead of executing the command, git_remote_branch will simply output the list of commands you need to run to accomplish that goal.
  Example: 
    grb explain create
    grb explain create my_branch github
  
  All commands also have aliases:
  #{ COMMANDS.keys.map{|k| k.to_s}.sort.map {|cmd| 
    "#{cmd}: #{COMMANDS[cmd.to_sym][:aliases].join(', ')}" }.join("\n  ") }
  HELP
  end

  def execute_action(action, branch_name, origin, current_branch)
    cmds = COMMANDS[action][:commands].map{ |c| eval(c) }.compact
    execute_cmds(cmds)
  end

  def explain_action(action, branch_name, origin, current_branch)
    cmds = COMMANDS[action][:commands].map{ |c| eval(c) }.compact

    puts "List of operations to do to #{COMMANDS[action][:description]}:", ''
    puts_cmd cmds
    puts ''
  end

  def execute_cmds(*cmds)
    cmds.flatten.each do |c|
      puts_cmd c
      `#{c}`
      puts ''
    end
  end

  def puts_cmd(*cmds)
    cmds.flatten.each do |c|
      puts "#{c}".red
    end
  end
end
