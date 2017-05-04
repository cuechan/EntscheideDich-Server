#!/usr/bin/perl

#--------------------------------------------------------------------------------#
# MIT License                                                                    #
#                                                                                #
# Copyright (c) 2017 Paul Maruhn <paulmaruhn@gmail.com>.                         #
#                                                                                #
# Permission is hereby granted, free of charge, to any person obtaining a copy   #
# of this software and associated documentation files (the "Software"), to deal  #
# in the Software without restriction, including without limitation the rights   #
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      #
# copies of the Software, and to permit persons to whom the Software is          #
# furnished to do so, subject to the following conditions:                       #
#                                                                                #
# The above copyright notice and this permission notice shall be included in all #
# copies or substantial portions of the Software.                                #
#                                                                                #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     #
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       #
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    #
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         #
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  #
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  #
# SOFTWARE.                                                                      #
#--------------------------------------------------------------------------------#



package EntscheideDich::Utils 0.01;

use warnings;
use strict;

use Carp;
use Data::Dumper;
use Digest::MD5 qw(md5_hex);
use feature 'say';
use JSON::XS;
use List::MoreUtils ':all';
use Math::Round 'nearest';
use MongoDB;
use POSIX qw(strftime);
use Term::ANSIColor;
use Time::Moment;
use Exporter 'import';

our @EXPORT = ("get_collection");





sub get_collection {
    my $collection = shift;

    my $mongoclient = MongoDB::MongoClient->new(
        host => 'mongodb://10.8.0.1',
        bson_codec => MongoDB::BSON->new(
            prefer_numeric => 1,
            dt_type        => 'Time::Moment'
        ),
    );

    my $mongodb = $mongoclient->get_database('EntscheideDich');
    return $mongodb->get_collection($collection);
}


sub decode_json_from_handle {
    my $fh = shift;

    my $json_str;
    while ($fh->read(my $buffer, 8)) {
        $json_str .= $buffer;
    }

    if (!$json_str) {
        return;
    }
    else {
        return decode_json($json_str // {});
    }

}




sub get_all_questions {
    my $self = shift;
    my $opt = shift;
    my $db_questions = get_collection("Questions");


    my $cursor = $db_questions->find({});
    my @all_questions;

    while (my $doc = $cursor->next()) {
        my $question = EntscheideDich::Question->new_from_doc($doc);

        push(@all_questions, $question);
    }


    return \@all_questions;
}





1;
