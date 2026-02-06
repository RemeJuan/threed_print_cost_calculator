bump_fix:
	./version-bump.sh patch

bump_feat:
	./version-bump.sh minor

bump_build:
	./version-bump.sh build

fix_ios:
	fvm flutter precache --ios && cd ios && rm Podfile.lock && pod install --repo-update && cd ..

flutter_test:
	fvm flutter test test --no-pub --test-randomize-ordering-seed random

flutter_generate:
	fvm flutter packages pub run build_runner build --delete-conflicting-outputs
