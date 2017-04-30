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


use warnings;
use strict;

use lib './lib';
use Carp;
use Data::Dumper;
use Digest::MD5 qw(md5_hex);
use EntscheideDich;
use EntscheideDich::Admin;
use EntscheideDich::API;
use feature 'say';
use JSON::XS;
use List::MoreUtils ':all';
use Math::Round 'nearest';
use Path::Router;
use Plack::App::Path::Router::PSGI;
use Plack::Request;
use Plack::Response;
use POSIX qw(strftime);



my $router = Path::Router->new;

$router->add_route('/api/update_questions', target => \&EntscheideDich::API::update_questions);
$router->add_route('/api/all_questions',    target => \&EntscheideDich::API::get_all_questions);
$router->add_route('/api/vote',             target => \&EntscheideDich::API::vote);

$router->add_route('/',
    target => sub {
        return [
            200,
            ["Content-Type" => "text/plain"],
            [qx(fortune -s)]
        ]
    }
);



my $app = Plack::App::Path::Router::PSGI->new(router => $router)->to_app;
