#!/usr/bin/env perl

use strict;
use warnings;

use inc::Module::Install 0.91;

use Module::Install::AuthorRequires 0.02;
use Module::Install::ReadmeFromPod 0.06;
use Module::Install::Repository 0.06;
use Module::Install::ExtraTests 0.006;

name 'String-TrigramSimilarity';
all_from 'lib/String/TrigramSimilarity.pm';
readme_from 'lib/String/TrigramSimilarity.pm' => 'clean';
auto_set_repository;

requires 'List::Util'                 => 0;

test_requires 'Test::Most'            => '0.21';
test_requires 'Test::More'            => '0.92';
test_requires 'Test::Differences'     => '0.4801';
test_requires 'Test::Deep'            => '0.103';
test_requires 'FindBin'               => 0;
test_requires 'Path::Class'           => '0.16';

author_requires 'Guard'               => '1.022';
author_requires 'IO::Capture::Stderr' => 0;
author_requires 'IO::Capture::Stdout' => 0;
author_requires 'Test::Benchmark'     => '0.04';
author_requires 'Test::Pod'           => '1.22';
author_requires 'Test::Pod::Coverage' => '1.08';
author_requires 'Pod::Coverage'       => '0.18';
author_requires 'Test::Perl::Critic'  => '1.01';

extra_tests;

auto_install;

WriteAll;
