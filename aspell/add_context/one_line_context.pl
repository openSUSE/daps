#! /usr/bin/perl -w
#
# grab three lines of context, and reformat it as one line.
#
# 2009-08-12, jw, v0.3  - protected xml markup in html output better
#
# Usage: 
#  
# ./one_line_context.pl Jakub ../../../books/en/xml
# ./one_line_context.pl wordlist.txt ../../../books/en/xml
# call it either with a wordlist or with a word.
#
# TODO: 
#  - run grep in --color=always mode, parse the wdiff colors
#  - add -a option to print all matches,  not just the first one.


my $list = shift || "../aspell_unknown_words_2009_07_15.txt";
my $where = shift || "../../../books/en/xml";

open LI, "<", $list or exit find_context($list, $where, {all => 1, verbose => 1});
print "<table>\n";
my $n = 1;
while (defined(my $word = <LI>))
  {
    chomp $word;
    find_context($word, $where, {as_html => 1, highlight => 1});
    printf STDERR " %s %d\r", $word, $n++ unless -t STDOUT; 
#    last if $word eq 'adminc';
  }
print "</table>\n";

#################################################
exit 0;

sub emit_one
{
  my ($word, $filename, $text, $opt) = @_;

  if ($opt->{as_html})
    {
      $text =~ s{<}{&lt;};
      $text =~ s{>}{&gt;};
      $text =~ s{\Q$word\E}{***<b>$word</b>***} if $opt->{highlight};
      print "<tr><td></td><td>$word</td><td>$filename</td><td><font size=-4>$text</td></tr>\n";
    }
  else
    {
      $text =~ s{\Q$word\E}{***$word***} if $opt->{highlight};
      print "$word $filename '$text'\n";
    }
}

sub find_context
{
  my ($word, $where, $opt) = @_;
  my $cmd = "cd $where && env 'GREP_COLORS=ms=01;31:mc=01;31:sl=:cx=:fn=35:ln=32:bn=32:se=36:rv' grep -n -T --color=always -H -C1 -w -m1 $word *.xml";
  $cmd .= "| head -3" unless $opt->{all};
  print STDERR "[$cmd]\n" if $opt->{verbose};
  open IN, "-|", $cmd;

  my $filename;
  my $text;
  while (defined(my $line = <IN>))
    {
      chomp $line;
      # remove all clear EOL escapes 
      $line =~ s{\033\[K}{}g;
      die "\Q$line\E\n";
      if ($line =~m{^(\S+\.xml)[-:]\s*(.*)$})
        {
	  $filename = $1;
	  $text .= "$2 ";
  	  $filename =~ s{[-:]$}{};
	}
      if ($line eq '--')
        {
  	  emit_one($word, $filename, $text, $opt->{as_html}) if $filename;
	  $filename = '';
	  last unless $opt->{all};
	}
    }
  close IN;

  # just in case there was no '--' line
  emit_one($word, $filename, $text, $opt->{as_html}) if $filename;
}
