# Extension on pub_semver

## Setting a version part
```dart
print(Version.parse('0.1.3+foo.1').change(major: 2, build: ['moo'])); // 2.1.3+moo
```

## Bumping the build part
```dart
print(Version.parse('1.2.3').nextBuild); // 1.2.3+1
print(Version.parse('1.2.3+foo42').nextBuild); // 1.2.3+foo42.1
print(Version.parse('1.2.3+foo.1.2.3.bar').nextBuild); // 1.2.3+foo.2.0.0.bar
```
