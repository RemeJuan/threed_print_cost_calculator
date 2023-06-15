bump_fix:
	./version-bump.sh patch

bump_feat:
	./version-bump.sh minor

fix_ios:
	fvm flutter precache --ios && cd ios && rm podfile.lock && arch -x86_64 pod install --repo-update && cd ..