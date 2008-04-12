#!perl

use strict;
use warnings;
use Test::More;
use Module::Build;

eval "use Net::SNMP";
plan skip_all => "Net::SNMP required for testing Net::SNMP::Mixin module"
  if $@;

eval "use Net::SNMP::Mixin";
plan skip_all =>
  "Net::SNMP::Mixin required for testing Net::SNMP::Mixin module"
  if $@;

plan tests => 10;

#plan 'no_plan';

is( Net::SNMP->mixer('Net::SNMP::Mixin::Dot1abLLDP'),
  'Net::SNMP', 'mixer returns the class name' );

my $builder        = Module::Build->current;
my $snmp_agent     = $builder->notes('snmp_agent');
my $snmp_community = $builder->notes('snmp_community');
my $snmp_version   = $builder->notes('snmp_version');

SKIP: {
  skip '-> no live tests', 9, unless $snmp_agent;

  my ( $session, $error ) = Net::SNMP->session(
    hostname  => $snmp_agent,
    community => $snmp_community || 'public',
    version   => $snmp_version || '2c',
  );

  ok( !$error, 'got snmp session for live tests' );
  isa_ok( $session, 'Net::SNMP' );
  ok(
    $session->can('get_lldp_local_system_data'),
    'can $session->get_lldp_local_system_data'
  );
  ok( $session->can('get_lldp_rem_table'),
    'can $session->get_lldp_rem_table' );

  eval { $session->init_mixins };
  ok( !$@, 'init_mixins successful' );

  eval { $session->init_mixins(1) };
  ok( !$@, 'already initalized but reload forced' );

  eval { $session->init_mixins };
  like(
    $@,
    qr/already initalized and reload not forced/i,
    'already initalized and reload not forced'
  );

  my $lldp_local_system_data;
  eval { $lldp_local_system_data = $session->get_lldp_local_system_data };
  ok( !$@, 'get_lldp_local_system_data' );

  my $lldp_rem_table;
  eval { $lldp_rem_table = $session->get_lldp_rem_table };
  ok( !$@, 'get_lldp_rem_table' );
}

# vim: ft=perl sw=2
