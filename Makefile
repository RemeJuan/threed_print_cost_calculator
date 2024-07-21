bump_fix:
	./version-bump.sh patch

bump_feat:
	./version-bump.sh minor

bump_build:
	./version-bump.sh build

fix_ios:
	fvm flutter precache --ios && cd ios && rm Podfile.lock && arch -x86_64 pod install --repo-update && cd ..

flutter_test:
	fvm flutter test test --no-pub --test-randomize-ordering-seed random
