current_zsh_version=$(zsh --version | awk '{print $2}')
expected_zsh_version=5.2
version_is_less_than=$(bc <<< "$current_zsh_version < $expected_zsh_version")

if [ "$version_is_less_than" == 1 ]; then
brew install zsh --force
fi

kubectl_version=$(kubectl version --client | grep master) > /dev/null 

if [ $? -gt 0 ] || [ -z "$kubectl_version" ]; 
then
    brew uninstall kubectl --force
    brew install kubectl --HEAD
fi

