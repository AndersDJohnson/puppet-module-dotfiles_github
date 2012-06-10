# dotfiles_github from AndersDJohnson

class dotfiles_github {}

define dotfiles_github_user( $user, $home_dir ) {
	
	# notify {"dotfiles_github":}
	
	# exec defaults
	Exec {
		path		=> '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
		logoutput	=> true,
	}
	
	#
	
	# clone from the git repo
	
	$clone_dir = "${home_dir}/.dotfiles"
	$git_url = "https://github.com/AndersDJohnson/dotfiles"
	
	$exec_clone = "${home_dir}.clone"

	exec { $exec_clone:
		command => "git clone --recursive ${git_url} ${clone_dir}",
		creates =>	$clone_dir,
		require => Package["git"],
	}
	
	#

	# do recursive git fetch

	#$ext_opts = "--git-dir=\"$clone_dir/.git\" --work-tree=\"$clone_dir\" "
	$ext_opts = "--git-dir=\"$clone_dir/.git\""
	
	$exec_fetch = "${clone_dir}.fetch"
	$exec_submodule = "${clone_dir}.submodule"

	exec {
		$exec_fetch:
			command	=> "git ${ext_opts} fetch",
			require	=> Exec[$exec_clone];
		$exec_submodule:
			command	=> "git ${ext_opts} submodule foreach git fetch",
			require	=> Exec[$exec_clone];
	}
	
	#
	
	# set permissions
	
	file {
		"${clone_dir}":
			ensure	=> present,
			mode	=> '0600',
			owner	=> $user,
			recurse	=> true,
			require	=> Exec[$exec_fetch, $exec_submodule];
	}
	
	#

}
