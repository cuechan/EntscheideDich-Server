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



package EntscheideDich::Question 0.01;

use warnings;
use strict;

use Carp;
use Data::Dumper;
use Digest::MD5 qw(md5_hex);
use Encode;
use feature 'say';
use JSON::XS;
use List::MoreUtils ':all';
use Math::Round 'nearest';
use MongoDB;
use POSIX qw(strftime);
use Term::ANSIColor;



sub new {
    my $class = shift;
    my $opt = shift;
    my $self = bless({}, $class);


    #$self->{id}             = $opt->{id}             or die "field is missing";
    $self->{question}       = $opt->{question}       or die "field is missing";
    $self->{guest}          = $opt->{guest}          or die "field is missing";
    $self->{youtube_link}   = $opt->{youtube_link}   // "";
    $self->{answer_1}       = $opt->{answer_1}       // "";
    $self->{answer_2}       = $opt->{answer_2}       // "";
    $self->{answer_1_count} = $opt->{answer_1_count} // 0;
    $self->{answer_2_count} = $opt->{answer_2_count} // 0;
    $self->{keywords}       = $opt->{keywords}       // [];

    return $self;
}



sub new_from_doc {
    my $class = shift;
    my $opt = shift;
    my $self = bless({}, $class);


    $self->{_id}            = $opt->{_id}            or die "field is missing";
    $self->{id}             = $opt->{id}             or die "field is missing";
    $self->{question}       = $opt->{question}       or die "field is missing";
    $self->{guest}          = $opt->{guest}          or die "field is missing";
    $self->{youtube_link}   = $opt->{youtube_link}   // "";
    $self->{answer_1}       = $opt->{answer_1}       // "";
    $self->{answer_2}       = $opt->{answer_2}       // "";
    $self->{answer_1_count} = $opt->{answer_1_count} // 0;
    $self->{answer_2_count} = $opt->{answer_2_count} // 0;
    $self->{keywords}       = $opt->{keywords}       // [];


    return $self;
}


sub checksum {
    my $self = shift;
    my $opt = shift;


    return if !exists $self->{question};
    return if !exists $self->{guest};
    return if !exists $self->{youtube_link};
    return if !exists $self->{answer_1};
    return if !exists $self->{answer_2};
    return if !exists $self->{answer_1_count};
    return if !exists $self->{answer_2_count};

    return md5_hex(
        encode_utf8($self->{question}),
        encode_utf8($self->{guest}),
        encode_utf8($self->{youtube_link}),
        encode_utf8($self->{answer_1}),
        encode_utf8($self->{answer_2}),
        $self->{answer_1_count},
        $self->{answer_2_count},
    );
}


sub export {
    my $self = shift;
    my $opt = {%$self};

    delete $opt->{_id};
    return {%$opt, checksum => $self->checksum};
}


1;
