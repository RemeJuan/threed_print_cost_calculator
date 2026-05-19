import os

TEMPLATE_PATH = '/Users/remelehane/Projects/threed_print_cost_calculator/templates/issue_doc_stub.md'
ISSUE_ID = 'b912ac41d193161e542d238bcb065645'
DEST_PATH = f'/Users/remelehane/Projects/threed_print_cost_calculator/docs/issues/{ISSUE_ID}.md'
FIREBASE_URI = 'https://console.firebase.google.com/v1/appid/project/d-print-cost-calculator-cf650/crashlytics/app/1:476308766683:android:7fc07cf44f4526bc0c31fe/issues/b912ac41d193161e542d238bcb065645?&time=1778544000000:1779235199000'

with open(TEMPLATE_PATH, 'r') as f:
    content = f.read()

content = content.replace('<issue-id>', ISSUE_ID)
content = content.replace('<deep link>', FIREBASE_URI)
content = content.replace('<detailed error message/subtitle>', "com.getkeepsafe.relinker.ApkLibraryInstaller.installLibrary - a3.b - Could not find 'libflutter.so'. Looked for: [arm64-v8a, armeabi-v7a, armeabi], but only found: [].")

with open(DEST_PATH, 'w') as f:
    f.write(content)

print(f'Created {DEST_PATH}')
