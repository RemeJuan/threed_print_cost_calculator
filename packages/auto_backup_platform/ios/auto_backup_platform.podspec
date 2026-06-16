Pod::Spec.new do |s|
  s.name             = 'auto_backup_platform'
  s.version          = '0.0.1'
  s.summary          = 'Native destination access for scheduled backups.'
  s.description      = 'Native destination access for scheduled backups.'
  s.homepage         = 'https://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'None' => 'none@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'auto_backup_platform/Sources/auto_backup_platform/**/*'
  s.dependency 'Flutter'
  s.platform         = :ios, '13.0'
  s.swift_version    = '5.0'
end
