use inc::Module::Install;

name     'PSPP';
all_from 'lib/PSPP.pm';

requires 'IPC::Run';
requires 'Text::CSV_XS';
requires 'File::Temp';
requires 'Carp';
requires_external_bin 'pspp';
build_requires 'Test::More';

no_index directory => 'examples';

WriteAll;

