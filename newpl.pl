# Author: yingjie.liu
# Date: 2009-10-14 星期三 
use Email::MIME;
use Email::Sender::Simple qw(sendmail);

if ( @ARGV == 0 ){
  print "Usage: newp <filename>\n";
	exit(1);
}
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
