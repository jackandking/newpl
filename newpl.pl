#!perl
# Author: jackandking@gmail.com
# DateTime: 2013-08-18 12:36:23
# HomePage: https://github.com/jackandking/newpl
# Change Log:
# 2013-10-10 2:05:14 PM add read_file so that upload can work; add proxy(opt -p) support.

our $__version__='0.2';

'Contributors:
    Yingjie.Liu@thomsonreuters.com
';

# Configuration Area Start for users of newpl
our $_author_ = 'Yingjie.Liu@thomsonreuters.com';
# Configuration Area End

our $_newpl_server_='newxx.sinaapp.com';
#our $_newpl_server_='localhost:8080';

use  HTTP::Request::Common qw(POST);
use LWP::UserAgent;


our $header=q{#!perl
# Author: %s
# DateTime: %s
# Generator: https://github.com/jackandking/newpl
# Newpl Version: %s
# Newpl ID: %s

};

our %sample_blocks =( 

    '0' => 
        ['Hello World',
q@
print "Hello:";
my $world=<STDIN>;
chomp($world);
my $World='perl is case sensitive';
print "Hello $world!\n";
@],

);

sub write_sample_to_file{
    my ($newpl_id, $samples, $filename)= @_;

    my @id_list;
    if(defined($samples)){ 
        @id_list = split(//,$samples);
    }else{
        @id_list=keys %sample_blocks;
    }
    
    my $file;
    if ($filename){
        open($file, ">$filename") or die("open failure");
    }else{
        $file=STDOUT;
    }
    
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
    my $dt=sprintf("%4d-%02d-%02d %02d:%02d:%02d",$year+1900,$mon+1,$mday,$hour,$min,$sec);
    printf $file $header, $_author_, $dt, $__version__, $newpl_id ;
    foreach my $i (@id_list){
        if($sample_blocks{"$i"} eq undef){
            print "invalid sample ID, ignore $i\n";
            next;
        }
        print $file "\n";
        print $file "=begin" if $options->comment;
        print $file '#'.$sample_blocks{$i}[0];
        print $file $sample_blocks{$i}[1];
        print $file "=end" if $options->comment;
        print $file "\n";
    }
    close($file) if $file != STDOUT;
}

sub list_sample(){
    print "Here are the available samples:\n";
    foreach my $i (sort(keys %sample_blocks)){
        print "$i => $sample_blocks{$i}[0]\n";
    }
    exit;
}

sub submit_record(){
    my ($what)=@_;
    $newplid=0;
    print("apply for newpl ID...") if !$options->quiet;
    my $ua = LWP::UserAgent->new;
    $ua->timeout(3);
    $ua->proxy(['http']=>$options->proxy) if($options->proxy);
    my $uri = "http://$_newpl_server_/newpl";
    my $req = POST($uri, ["which"=> $__version__, "who" => $_author_, "what" => $what]);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
        my $message = $resp->decoded_content;
        $newplid=$message;
        print "Received reply: $message\n" if $options->debug;
    } else {
        if($options->debug){
            print "HTTP POST error code: ", $resp->code, "\n";
            print "HTTP POST error message: ", $resp->message, "\n";
        }
    }

    if (!$options->quiet){
        if ($newplid >0){ 
            print "ok, got $newplid\n";
        } else  {
            print "ko, use 0\n"
        }
    }

    return $newplid
}
 
sub upload_file{
    #use File::Slurp;
    my ($filename)=@_;
    die("error: $filename does not exist!") unless -e $filename;
    open(my $file, "$filename") or die("open failure");
    my $newplid=0;
    while(my $line=<$file>){
        if($line=~/# Newpl ID: (\d+)/){
            $newplid=$1;
            break;
        }
    }
    close($file);
    if("$newplid" eq "0"){
        print "error: no valid newpl ID found for $filename\n";
        exit;
    }
    print "uploading $filename(newplid=$newplid)...";
    my $ua = LWP::UserAgent->new;
    $ua->timeout(10);
    $ua->proxy(['http']=>$options->proxy) if($options->proxy);
    my $uri = "http://$_newpl_server_/newpl/upload";
    my $content = read_file($filename);
    my $req = POST($uri, ["filename"=> $filename, "content" => $content]);
    my $resp = $ua->request($req);
    if ($resp->is_success) {
        my $message = $resp->decoded_content;
        print "$message\n";
        print "weblink: http://$_newpl_server_/newpl/$newplid\n";
    } else {
        if($options->debug){
            print "HTTP POST error code: ", $resp->code, "\n";
        }
        print "ko ", $resp->message, "\n";
    }
    exit
}

sub read_file(){
    my ($a_filename)=@_;
    my $l_cont= do {
        local $/ = undef;
        open my $fh, "<", $a_filename
            or die "could not open $a_filename: $!";
        <$fh>;
    };
    return $l_cont
}

our $options;
sub main(){
    use Getopt::Long::Descriptive;

    ($options, my $usage) = describe_options(
        '%c %o <filename>',
        [ 'help|h',       "show this help message and exit" ],
        [ 'list|l', "list all the available samples." ],
        [ 'samples|s=s', "select samples to include in the new file, e.g -s 123", {default=>''} ],
        [ 'comment|c', "add samples as comment." ],
        [ 'overwrite|o', "overwrite existing file." ],
        [ 'quiet|q', "run in silent mode." ],
        [ 'test|t', "run in test mode." ],
        [ 'debug|d', "run in debug mode." ],
        [],
        [ 'upload|u=s',   "upload file to newpl server." ],
        [ 'norecord|n',  "don't submit record to improve newpl" ],
        [ 'proxy|p=s',   "set http proxy, e.g.: http://10.40.14.34:80" ],
    );

    print($usage->text), exit if $options->help;
    &list_sample if $options->list;
    &upload_file($options->upload) if $options->upload;

    if (scalar(@ARGV)!= 1){
        print "incorrect number of arguments, try -h\n";
        exit;
    }

    $filename=$ARGV[0].'.pl';
    if (!$options->overwrite and -e $filename){
        print("error: $filename already exist!\n");
        exit;
    }

    my $newpl_id=0;
    if (!$options->test){
        $newpl_id=&submit_record($options->samples);
    }

    &write_sample_to_file($newpl_id,
                         #defined($options->samples)?$options->samples:'',
                         $options->samples,
                         $options->test ? undef : $filename);
    print "generate $filename successfully.\n" if !$options->quiet;
}


=pod




my $fn=$ARGV[0].".pl";
if(-e "$fn") {
	die("$fn exsit!\n");
}
open(NEWP,">$fn") || die("could not create file\n");
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
my $dt=sprintf("%4d-%02d-%02d %02d:%02d:%02d",$year+1900,$mon+1,$mday,$hour,$min,$sec);
my $header="# Author: yingjie.liu\@thomsonreuters.com
# DateTime: ".$dt."\n";
print NEWP $header;

my $examples='
#=========examples===========
## hash table
#my %src=(
#	"a"=>1,
#	"b"=>2,
#);
#foreach my $url (values %src){
#foreach my $key (keys %src){
#	my $url=$src{$key};

## read file
# open(FILE,"$filename") || die("could not open $filename\n");
# while($line=<FILE>){
# close(FILE);

## write file
# open(FILE,">$filename") || die("could not open $filename\n");
# print FILE $something;

## datetime
#my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
#my $dt=sprintf("%4d-%02d-%02d %02d:%02d:%02d",$year+1900,$mon+1,$mday,$hour,$min,$sec);

## read input param
# my $keyword="defaltvalue";
# $keyword=$ARGV[0] if @ARGV >0;

## new process
#my $ProcessObj;
#Win32::Process::Create($ProcessObj, "C:\\WINDOWS\\system32\\cmd.exe", "cmd /k C:\\perl\\bin\\perl.exe $cmd -u \"$url\" -k $keyword", 0, DETACHED_PROCESS,".")|| die("process create failed!");
#print $ProcessObj->GetProcessID(),"\n";

## split, join
#@items=split /,/,$line;
#chomp(@items);
#join ",",@items[$s_ric_begin..$s_ric_end]

## string cmp
#$str eq "something"
#"$str" ne "something"

';
print NEWP $examples;

print "$fn created!\n";

exit;

my $hn=system("hostname");
chomp($hn);
print "$hn\n";

# first, create your message
my $message = Email::MIME->create(
  header_str => [
    From    => 'jackandking@gmail.com',
    To      => 'jackandking@gmail.com',
    Subject => "jpsoft: new perl <$fn> created from host <$hn>",
  ],
  attributes => {
    encoding => 'quoted-printable',
    charset  => 'ISO-8859-1',
  },
  body_str => "$dt\n",
);

# send the message
sendmail($message);

print "$fn logged via email!\n"
=cut

unless(caller){
    main();
}

