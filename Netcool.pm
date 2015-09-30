package Netcool;
use strict;
use warnings;
use Env qw(NCHOME OMNIHOME R);

sub new
{

    my $class = shift;
    my $self = {};
    my $syntax = shift || "$OMNIHOME/probes/nco_p_syntax -server WF_COL_P1 -rulesfile";
    $self->{syntax} = $syntax;

    bless $self, $class;
    return $self;

}
sub set
{
    my $self = shift;
    my $field = shift;
    $self->{$field} = shift;

}
sub get
{
    my $self = shift;
    my $field = shift;
    return $self->{$field};
}

sub syntax_check
{
    my $self = shift;

    # status = 1 -> passed syntax check
    my $status = 1;
    my $command = `$self->{syntax}`;
    if ( $command =~ /Rules file syntax OK/ )
    {
        $status = $status;
    }
    else
    {
        $status = 0;
    }

    return $status;
}
sub restart {

    my $self = shift;
    my $rules = shift;
    chomp($rules);
    my $result;
    my $proc = `/bin/ps -ef | grep -e "$rules.props" | grep -v grep`;
    my(@tmp,$hupit);
    if(length( $proc )>1)
    {
        chomp($proc);
        @tmp = split( /\s+/, $proc );
        chomp($tmp[1]);
        system("/bin/kill -HUP $tmp[1]");
        if($? == 0)
        {
            print "success: reloaded process id :$tmp[1]\n";
            $result = 1;
        }
        else
        {
            print "failed: reloaded process id :$tmp[1]\n";
            $result = 0;
        }
    }
    else
    {
        $result ="unable to find a process name containing $rules.props";

    }
    return $result;

}


sub pastart {

    ######################################################
    # pacontrol:                                         #
    #- pastart takes the process name from pa and starts #
    ######################################################
    my $self = shift;
    my $proc = shift; # PA process name
    my $pa_server = shift; # PA server name
    my $creds = "-user emtssysi -password 3mtsInfo";
    my $pa = "$NCHOME/omnibus/bin/nco_pa_start";
    my $result = 1; # pa cmd ran successfully
    chomp($pa_server, $proc);
    my $command = `$pa -server $pa_server -process $proc $creds 2>&1`;

    if ( $command =~ /Error/ )
    {
      print "Error when running nco_pa_start";
      $result = 0;
    }
    else
    {
      $result = $result;
    }
    return $result;

}
sub pastop {

    ######################################################
    # pacontrol:                                         #
    #- pastop takes the process name from pa and stops   #
    ######################################################
    my $self = shift;
    my $proc = shift; # PA process name
    my $pa_server = shift; # PA server name
    my $creds = "-user emtssysi -password 3mtsInfo -process";
    my $pa = "$NCHOME/omnibus/bin/nco_pa_stop";
    my $result = 1; # pa cmd ran successfully
    chomp($pa_server, $proc);

    my $command = `$pa -server $pa_server -process $proc $creds 2>&1`;

    if ( $command =~ /Error/ )
    {
     print "Error when running nco_pa_stop";
     $result = 0;
    }
    else
    {
        $result = $result;
    }
    return $result;

}

1;
