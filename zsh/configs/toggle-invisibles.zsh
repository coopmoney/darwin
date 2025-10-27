
toggleInvisibles() {
is_set=$(defaults read com.apple.finder AppleShowAllFiles)
if [ $is_set ] ; then
  defaults write com.apple.finder AppleShowAllFiles FALSE
else
  defaults write com.apple.finder AppleShowAllFiles TRUE
fi
killall Finder
}
