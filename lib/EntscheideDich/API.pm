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



package EntscheideDich::API 0.01;

use warnings;
use strict;

use Carp;
use Data::Dumper;
use feature 'say';
use JSON::XS;
use EntscheideDich::Question;
use EntscheideDich::Utils;






sub update_questions {
    my $psgi = Plack::Request->new(shift);
    my $fh = $psgi->body();

    my $client_db = EntscheideDich::Utils::decode_json_from_handle($fh);


    my $add;
    my $update;
    my $delete;


    my $all_quests = EntscheideDich::Utils::get_all_questions();


    my $returnmet;


    return [
        200,
        ["Content-Type" => "text/plain"],
        ["ok"]
    ]
}


sub get_all_questions {
    my $psgi = Plack::Request->new(shift);
    my $fh = $psgi->body();

    my $json_str;

    open(my $data, '<', <DATA>);
    while (my $line = <DATA>) {
        $json_str .= $line;
    }


    my @all_quests = decode_json($json_str);

    return [
        200,
        ["Content-Type" => "text/plain"],
        [encode_json({})]
    ]
}



1;
