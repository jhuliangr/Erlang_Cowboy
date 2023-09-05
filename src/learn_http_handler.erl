-module(learn_http_handler).
-behaviour(cowboy_handler).

-export([init/2]).

init(Req0, State) ->
    Req = cowboy_req:reply(200, 
    #{<<"content-type">> => <<"text/html">>}, 
    <<"<html>
            <head>
                <title>Main Page</title>
            </head>
            <body>
                <h1>Simple page to test Cowboy</h1>
                <a href='WsTestPage'><button>Websocket test page</button></a>
            </body>
        </html>">>, 
    Req0),
    io:format("/~n",[]),
    {ok, Req, State}.