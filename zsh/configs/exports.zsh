
# for rvm permissions
export rvmsudo_secure_path=1

#dropbox shortcut
alias dbx='~/Library/CloudStorage/Dropbox'


# check if gopath exists
if type "go" > /dev/null; then
  export PATH="$(go env GOPATH)/bin:$PATH"
fi
