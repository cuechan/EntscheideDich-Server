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
use Plack::Request;
use Plack::Response;






sub update_questions {
    my $env = shift;
    my $psgi = Plack::Request->new($env);
    my $fh = $psgi->body();
    my $client_db = EntscheideDich::Utils::decode_json_from_handle($fh);


    unless ($client_db) {
        # the client havent sent any data
        # assuming the client dont have any questions

        $client_db = {
            i_have => []
        }
    }



    my $add = [];
    my $update = [];
    my $delete = [];

    my $all_quests = EntscheideDich::Utils::get_all_questions();


    # convert array to hash

    my %client_quests = map {$_->{id} => $_->{checksum}} @{$client_db->{i_have}};


    foreach my $question (@$all_quests) {
        # here is the magic!

        if (exists $client_quests{$question->{id}}) {
            # ok the questions exists. lets check the checksum
            if ($client_quests{$question->{id}} ne $question->checksum) {
                # the question has changed

                push(@$update, $question->export);
            }
        }
        else {
            # the question does not exist

            push(@$add, $question->export);
        }

        delete $client_quests{$question->{id}};
    }


    push(@$delete, $_) foreach (keys %client_quests);


    my $returnmet = {
        add => $add,
        update => $update,
        delete => $delete
    };


    my $psgi_res = Plack::Response->new(200);
    $psgi_res->body(encode_json($returnmet));
    $psgi_res->header("Content-Type" => "text/plain; charset=UTF-8");
    return $psgi_res->finalize;
}


sub get_all_questions {
    my $psgi = Plack::Request->new(shift);
    my $psgi_res = Plack::Response->new(200);
    my $req = EntscheideDich::Utils::decode_json_from_handle($psgi->body);


    my $all_questions = EntscheideDich::Utils::get_all_questions();


    foreach my $quest (@$all_questions) {
        $quest = $quest->export;
    }



    $psgi_res->body(encode_json($all_questions));
    $psgi_res->header("Content-Type" => "text/plain; charset=UTF-8");

    return $psgi_res->finalize;
}


sub vote {
    my $psgi = Plack::Request->new(shift);
    my $req = EntscheideDich::Utils::decode_json_from_handle($psgi->body);
    my $res = Plack::Response->new(200);
    $res->header("Content-Type" => "text/plain");

    my $db_votes = get_collection("Votings");


    if (ref $req->{i_vote} ne 'ARRAY') {
        $res->status(400);
        $res->body("'i_vote' is  not an array");
        return $res->finalize;
    }

    my $device_id = $req->{device_id};

    if (!$device_id or $device_id !~ m/[0-9a-f]{32}/i) {
        $res->status(400);
        $res->body("'device_id' is not valid");
        return $res->finalize;
    }


    foreach my $voting (@{$req->{i_vote}}) {
        $db_votes->update_one(
            {
                device_id => $device_id,
                question_id => $voting->{id}
            },
            {'$set' => {
                "answer" => $voting->{answer}
            }},
            {upsert => 1}
        );
    }



    $res->body(encode_json({err => 0, message => "success"}));

    return $res->finalize;
}



1;
