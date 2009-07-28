use inc::Module::Install;

name     'PSPP';
all_from 'lib/PSPP.pm';
author   'Patrick Donelan <pat@patspam.com>';
license  'perl';

build_requires 'Test::More';

auto_install;

WriteAll;

