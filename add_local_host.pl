#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use feature 'say';

my $HOSTS_FILE = '/etc/hosts';
# my $HOSTS_FILE = '/tmp/hosts';
my $NGINX_AVA = '/etc/nginx/sites-available/';
# my $NGINX_AVA = '/tmp/ava/';

my $NGINX_ENA = '/etc/nginx/sites-enabled/';
# my $NGINX_ENA = '/tmp/ena/';

my $WORK_DIR_PREFIX = '/home/asd/workspace/';

my $hostname = $ARGV[0] or usage();

sub usage {
    say 'Usage:';
    say "$0 <hostname>";
    exit();
}

sub add_to_hosts {
    my ($hostname) = @_;
    $hostname or die 'No hostname given';

    my $exist = 0;
    open(my $h_read, '<', $HOSTS_FILE) or die $!;
    while (my $str = <$h_read>) {
        next if $str =~ /^#/;
        if ($str =~ /^[.\d]+\s+$hostname$/) {
            $exist = 1;
            last;
        }
    }
    close $h_read;
    return if $exist;

    open(my $h_add, '>>', $HOSTS_FILE) or die $!;
    print $h_add "127.0.0.1\t$hostname\n";
    close $h_add;
}

add_to_hosts($hostname);

my $ava_file = $NGINX_AVA . $hostname;
open(my $ava, '>', $ava_file) or die $!;
print $ava <<END;
server {
    listen 80;
    server_name $hostname;
    root ${WORK_DIR_PREFIX}${hostname};
    index index.html;
}
END

my $enabled_file = $NGINX_ENA . $hostname;
symlink($ava_file, $enabled_file);

say "Ok Run:";
`sudo service nginx restart`;
say "http://$hostname";
