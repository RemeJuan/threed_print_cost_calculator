#/bin/sh
fvm flutter pub run cider bump $1 && \
git add pubspec.yaml CHANGELOG.md && \
git commit --amend
