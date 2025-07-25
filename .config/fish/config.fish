if status is-interactive
    # Commands to run in interactive sessions can go here
end

alias rndstr='openssl rand -base64 20 | tr -cd "[a-zA-Z0-9]";echo'
alias dockerkill='docker kill (docker ps -q)'
alias myip='curl ipinfo.io/ip'
alias ll='ls -l'
alias la='ls -la'
alias cs='xclip -selection clipboard'
alias speedtest='speedtest --simple'
alias config='/usr/bin/git --git-dir=$HOME/.cfg/.git/ --work-tree=$HOME'
alias vim='nvim'
alias python='python3'
alias ctop='docker run --rm -ti -v /var/run/docker.sock:/var/run/docker.sock --name ctop quay.io/vektorlab/ctop:latest'
alias disks='lsblk -o NAME,FSTYPE,SIZE,UUID,MOUNTPOINTS'
alias size='du -hs'
alias hash='sha256sum | awk "{print \$1}"'

function fish_prompt
	set_color brblack
	echo -n "["(date "+%H:%M")"] "
	set_color blue
	echo -n (hostname)
	if [ $PWD != $HOME ]
		set_color brblack
		echo -n ':'
		set_color yellow
		echo -n (basename $PWD)
	end
	set_color green
	printf '%s ' (__fish_git_prompt)
	set_color red
	echo -n '| '
	set_color normal
end

function fish_greeting
	echo
	echo -e (uname -ro | awk '{print " \\\\e[1mOS: \\\\e[0;32m"$0"\\\\e[0m"}')
	echo -e (uptime -p | sed 's/^up //' | awk '{print " \\\\e[1mUptime: \\\\e[0;32m"$0"\\\\e[0m"}')
	echo -e (uname -n | awk '{print " \\\\e[1mHostname: \\\\e[0;32m"$0"\\\\e[0m"}')
	echo -e " \\e[1mDisk usage:\\e[0m"
	echo
	echo -ne (\
		df -l -h | grep -E 'dev/(xvda|sd|mapper)' | \
		awk '{printf "\\\\t%s\\\\t%4s / %4s  %s\\\\n\n", $6, $3, $2, $5}' | \
		sed -e 's/^\(.*\([8][5-9]\|[9][0-9]\)%.*\)$/\\\\e[0;31m\1\\\\e[0m/' -e 's/^\(.*\([7][5-9]\|[8][0-4]\)%.*\)$/\\\\e[0;33m\1\\\\e[0m/' | \
		paste -sd ''\
	)
	echo

	echo -e " \\e[1mNetwork:\\e[0m"
	echo
	# http://tdt.rocks/linux_network_interface_naming.html
	echo -ne (\
		ip -4 addr show up scope global | \
			grep -E ': <|inet' | \
			sed \
				-e 's/^[[:digit:]]\+: //' \
				-e 's/: <.*//' \
				-e 's/.*inet[[:digit:]]* //' \
				-e 's/\/.*//'| \
			awk 'BEGIN {i=""} /\.|:/ {print i" "$0"\\\n"; next} // {i = $0}' | \
			sort | \
			column -t -R1 | \
			# public addresses are underlined for visibility \
			sed 's/ \([^ ]\+\)$/ \\\e[4m\1/' | \
			# private addresses are not \
			sed 's/m\(\(10\.\|172\.\(1[6-9]\|2[0-9]\|3[01]\)\|192\.168\.\).*\)/m\\\e[24m\1/' | \
			# unknown interfaces are cyan \
			sed 's/^\( *[^ ]\+\)/\\\e[36m\1/' | \
			# ethernet interfaces are normal \
			sed 's/\(\(en\|em\|eth\)[^ ]* .*\)/\\\e[39m\1/' | \
			# wireless interfaces are purple \
			sed 's/\(wl[^ ]* .*\)/\\\e[35m\1/' | \
			# wwan interfaces are yellow \
			sed 's/\(ww[^ ]* .*\).*/\\\e[33m\1/' | \
			sed 's/$/\\\e[0m/' | \
			sed 's/^/\t/' \
		)
	echo

	set_color normal
end

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /home/bordalo/miniconda3/bin/conda
    eval /home/bordalo/miniconda3/bin/conda "shell.fish" "hook" $argv | source
else
    if test -f "/home/bordalo/miniconda3/etc/fish/conf.d/conda.fish"
        . "/home/bordalo/miniconda3/etc/fish/conf.d/conda.fish"
    else
        set -x PATH "/home/bordalo/miniconda3/bin" $PATH
    end
end
# <<< conda initialize <<<

function nvm
    bash -c "source ~/.nvm/nvm.sh; nvm $argv"
end

set -x PATH $NVM_DIR/versions/node/v22.7.0/bin $PATH
