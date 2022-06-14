#! /usr/bin/env python3
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

import argparse
import xml.etree.ElementTree as ET
import os
import sys
import shutil
import atexit
import subprocess

# Use the project root as the working directory
prevdir = os.getcwd()
workdir = os.path.join(os.path.dirname(__file__), '..', '..')
os.chdir(workdir)
atexit.register(os.chdir, prevdir)

# Include only locales above this threshold (e.g. 70%) in production
l10n_threshold = 0.70

parser = argparse.ArgumentParser()
parser.add_argument(
    '-m', '--macos', default=False, action="store_true", dest="ismacos",
    help='Include the MacOS bundle data')
parser.add_argument(
    '-q', '--qt_path',  default=None, dest="qtpath",
    help='The QT binary path. If not set, we try to guess.')
args = parser.parse_args()

stepnum = 1
def title(text):
    global stepnum
    print(f"\033[96m\033[1mStep {stepnum}\033[0m: \033[97m{text}\033[0m")
    stepnum = stepnum+1

# Step 0
title("Find the Qt localization tools...")
def qtquery(qmake, propname):
    try:
        qtquery = os.popen(f'{qmake} -query {propname}')
        qtpath = qtquery.read().strip()
        if len(qtpath) > 0:
            return qtpath
    finally:
        pass
    return None

qtbinpath = args.qtpath
if qtbinpath is None:
  qtbinpath = qtquery('qmake', 'QT_INSTALL_BINS')
if qtbinpath is None:
    qtbinpath = qtquery('qmake6', 'QT_INSTALL_BINS')
if qtbinpath is None:
    qtbinpath = qtquery('qmake5', 'QT_INSTALL_BINS')
if qtbinpath is None:
    qtbinpath = qtquery('qmake-qt5', 'QT_INSTALL_BINS')
if qtbinpath is None:
    print('Unable to locate qmake tool.')
    sys.exit(1)

if not os.path.isdir(qtbinpath):
    print(f"QT path is not a diretory: {qtbinpath}")
    sys.exit(1)

lupdate = os.path.join(qtbinpath, 'lupdate')
lconvert = os.path.join(qtbinpath, 'lconvert')
lrelease = os.path.join(qtbinpath, 'lrelease')

# Step 0
# Let's update the i18n repo
os.system(f"git submodule init")
os.system(f"git submodule update --remote --depth 1 i18n")

# Step 1
# Go through the i18n repo, check each XLIFF file and take
# note which locale is complete above the minimum threshold.
# Adds path of .xliff and .ts to l10n_files.
title("Validate the XLIFF file...")
l10n_files = []
for locale in os.listdir('i18n'):
    # Skip non folders
    if not os.path.isdir(os.path.join('i18n', locale)):
        continue

    # Skip hidden folders
    if locale.startswith('.'):
        continue

    xliff_path = os.path.join('i18n', locale, 'mozillavpn.xliff')

    # If it's the source locale (en), ignore parsing for completeness and
    # add it to the list.
    if locale == 'en':
        print(f'OK\t- en added (reference locale)')
        l10n_files.append({
            'locale': 'en',
            'ts': os.path.join('translations', 'generated', 'mozillavpn_en.ts'),
            'xliff': xliff_path
        })
        continue

    tree = ET.parse(xliff_path)
    root = tree.getroot()

    sources = 0
    translations = 0

    for element in root.iter('{urn:oasis:names:tc:xliff:document:1.2}source'):
        sources += 1
    for element in root.iter('{urn:oasis:names:tc:xliff:document:1.2}target'):
        translations += 1

    completeness = translations/(sources*1.0)

    # Ignore locale with less than 70% of completeness
    if completeness < l10n_threshold:
        print(f'KO\t- {locale} is translated at {round(completeness*100, 2)}%, at least {l10n_threshold*100}% is needed')
        continue  # Not enough translations next file please

    print(f'OK\t- {locale} added ({round(completeness*100, 2)}% translated)')
    l10n_files.append({
        'locale': locale,
        'ts': os.path.join('translations', 'generated', f'mozillavpn_{locale}.ts'),
        'xliff': xliff_path
    })

# Step 2
title("Create folders and localization files for the languages...")
for file in l10n_files:
    locdirectory = os.path.join('translations', 'generated', file['locale'])
    os.makedirs(locdirectory, exist_ok=True)
    locversion = os.path.join(locdirectory, f'locversion.plist')
    with open(locversion, 'w') as locversion_file:
        locversion_file.write(f"""<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple Computer//DTD PLIST 1.0//EN\"
\"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
    <key>LprojCompatibleVersion</key>
    <string>123</string>
    <key>LprojLocale</key>
    <string>{file['locale']}</string>
    <key>LprojRevisionLevel</key>
    <string>1</string>
    <key>LprojVersion</key>
    <string>123</string>
</dict>
</plist>""")

with open(os.path.join('translations', 'generated', 'macos.pri'), 'w') as macospri:
    macospri.write('### AUTOGENERATED! DO NOT EDIT!! ###\n')
    for file in l10n_files:
        macospri.write(f"LANGUAGES_FILES_{file['locale']}.files += $$PWD/{file['locale']}/locversion.plist\n")
        macospri.write(f"LANGUAGES_FILES_{file['locale']}.path = Contents/Resources/{file['locale']}.lproj\n")
        macospri.write(f"QMAKE_BUNDLE_DATA += LANGUAGES_FILES_{file['locale']}\n\n")

# Step 3
title("Write resource file to import the locales that are ready...")
with open('translations/generated/translations.qrc', 'w') as qrcfile:
    qrcfile.write('<!-- AUTOGENERATED! DO NOT EDIT!! -->\n')
    qrcfile.write('<RCC>\n')
    qrcfile.write('    <qresource prefix="/i18n">\n')
    for file in l10n_files:
        qrcfile.write(f'        <file>mozillavpn_{file["locale"]}.qm</file>\n')
    qrcfile.write('    </qresource>\n')
    qrcfile.write('</RCC>\n')

# Step 4
title("Generate the Js/C++ string definitions...")
try:
    subprocess.call([sys.executable, os.path.join('scripts', 'utils', 'generate_strings.py'),
                     '-o', os.path.join('translations', 'generated'),
                     os.path.join('translations', 'strings.yaml')])
except Exception as e:
    print("generate_strings.py failed. Try with:\n\tpip3 install -r requirements.txt --user")
    print(e)
    exit(1)

# Build a dummy project to glob together everything that might contain strings.
title("Scanning for new strings...")
def scan_sources(projfile, dirpath):
    projfile.write(f"HEADERS += $$files({dirpath}/*.h, true)\n")
    projfile.write(f"SOURCES += $$files({dirpath}/*.cpp, true)\n")
    projfile.write(f"RESOURCES += $$files({dirpath}/*.qrc, true)\n\n")

with open('translations/generated/dummy.pro', 'w') as dummyproj:
    dummyproj.write('### AUTOGENERATED! DO NOT EDIT!! ###\n')
    dummyproj.write(f"HEADERS += l18nstrings.h\n")
    dummyproj.write(f"SOURCES += l18nstrings_p.cpp\n")
    dummyproj.write(f"SOURCES += ../l18nstrings.cpp\n\n")
    for l10n_file in l10n_files:
        dummyproj.write(f"TRANSLATIONS += {os.path.basename(l10n_file['ts'])}\n")

    dummyproj.write("\n")
    scan_sources(dummyproj, '../../src')
    scan_sources(dummyproj, '../../nebula')

# Step 5
title("Generate translation resources...")
for l10n_file in l10n_files:
    os.system(f"{lconvert} -if xlf -i {l10n_file['xliff']} -o {l10n_file['ts']}")
os.system(f"{lupdate} translations/generated/dummy.pro")
for l10n_file in l10n_files:
    os.system(f"{lrelease} -idbased {l10n_file['ts']}")

print(f'Imported {len(l10n_files)} locales')

git = os.popen(f'git submodule status i18n')
git_commit_hash = git.read().strip().replace("+","").split(' ')[0]
print(f'Current commit:  https://github.com/mozilla-l10n/mozilla-vpn-client-l10n/commit/{git_commit_hash}')
