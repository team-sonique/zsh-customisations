kubectl_bin=$(which kubectl) > /dev/null

if [ $? -eq 0 ]; 
then
    brew uninstall kubectl --force
fi

brew install kubectl --HEAD

kubectl completion zsh > /dev/null 2>&1
