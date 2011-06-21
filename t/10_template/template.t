use Test::More import => ['!pass'];

plan tests => 3;

use strict;
use warnings;

{
    use Dancer;

    setting views => path('t', '10_template', 'views');

    get '/' => sub {
        template 'index', {foo => 42};
    };
    get '/introspective' => sub {
        setting "include_view_name" => 1;
        template 'introspective_index', {foo => 42};
    };

    get '/introspective/custom' => sub {
        setting "include_view_name" => "custom";
        template 'introspective_custom_index', {foo => 42};
    };
}

use Dancer::Test;

response_content_is [GET => '/'], "foo => 42\n";

response_content_is [GET => '/introspective'], 
    "foo => 42\nview => introspective_index\n";

response_content_is [GET => '/introspective/custom'], 
    "foo => 42\nview => introspective_custom_index\n";
