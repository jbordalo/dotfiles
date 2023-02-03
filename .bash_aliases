alias rndstr='openssl rand -base64 20 | tr -cd "[a-zA-Z0-9]";echo'
alias dockerkill='docker kill $(docker ps -q)'
alias frontend='ssh -p 12034 -L 9999:node14:22 cad01@cluster.di.fct.unl.pt'
