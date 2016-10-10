brew switch zsh 5.2

kubectl_version=$(kubectl version --client | grep master) > /dev/null 

if [ $? -gt 0 ] || [ -z "$kubectl_version" ]; 
then
    brew uninstall kubectl --force
    brew install kubectl --HEAD
fi

kubectl completion zsh > /dev/null 2>&1
