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

flutter_cov:
	./scripts/coverage.sh

flutter_generate:
	fvm flutter packages pub run build_runner build --delete-conflicting-outputs

### Store metadata management ###

metadata_pull:
	./scripts/metadata_pull.sh

### Store screenshots ###

SCREENSHOTS_VENV = /tmp/screenshots_venv

generate_screenshots:
	[ -d $(SCREENSHOTS_VENV) ] || python3 -m venv $(SCREENSHOTS_VENV)
	$(SCREENSHOTS_VENV)/bin/pip install -q -r scripts/requirements_screenshots.txt
	$(SCREENSHOTS_VENV)/bin/python3 scripts/generate_screenshots.py --formats all

generate_screenshots_ios:
	$(SCREENSHOTS_VENV)/bin/python3 scripts/generate_screenshots.py --formats ios

generate_screenshots_android:
	$(SCREENSHOTS_VENV)/bin/python3 scripts/generate_screenshots.py --formats android

### Store metadata management ###

metadata_check_ios:
	bundle exec fastlane ios metadata_check

metadata_check_android:
	bundle exec fastlane android metadata_check

metadata_check_all:
	bundle exec fastlane metadata_check_all

metadata_push_ios:
	./scripts/metadata_push_ios.sh

metadata_push_ios_changelog:
	./scripts/metadata_push_ios_changelog.sh

metadata_push_android:
	./scripts/metadata_push_android.sh

metadata_push_android_changelog:
	./scripts/metadata_push_android_changelog.sh $(TRACK)

metadata_push_all:
	bundle exec fastlane metadata_push_all

screenshots_push_ios:
	./scripts/screenshots_push_ios.sh

screenshots_push_android:
	./scripts/screenshots_push_android.sh

screenshots_push_all:
	bundle exec fastlane screenshot_push_all

metadata_validate:
	./scripts/validate_metadata.sh

metadata_diff:
	./scripts/metadata_diff.sh

metadata_diff_ios:
	./scripts/metadata_diff.sh ios

metadata_diff_android:
	./scripts/metadata_diff.sh android
