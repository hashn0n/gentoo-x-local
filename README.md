# gentoo-x-local
git commit -a -m "" --dry-run
git clean -fd && \
git checkout -f && \
git fetch && \
git rebase origin && \
git reset --hard origin/master
