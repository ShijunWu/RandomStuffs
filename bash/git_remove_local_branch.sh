# Command to remove local branches that already gone in remote.
alias gbsfpruge="git fetch --all -p;git branch -vv | grep -E '[0-9|a-f]{7} \[origin/.*?: gone\]'"
alias gbspruge="gbsfpruge | awk '{ print \$1 }'"
alias _gbranchpruge="gbspruge | xargs -n 1 git branch -d"
alias _gbranchprugehard="gbspruge | xargs -n 1 git branch -D"
function _gbpruge {
        if [[ "$1" == "-d" ]]; then
                _gbranchpruge
        elif [[ "$1" == "-D" ]]; then
                _gbranchprugehard
        elif [[ "$1" == "-s" ]]; then
                gbspruge
        elif [[ "$1" == "-sf" ]]; then
                gbsfpruge
        else
                gbsfpruge
        fi
};

alias gbpruge='_gbpruge'