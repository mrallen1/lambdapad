%%% Copyright 2014 Mark Allen <mrallen1@yahoo.com>
%%%
%%% Licensed under the Apache License, Version 2.0 (the "License");
%%% you may not use this file except in compliance with the License.
%%% You may obtain a copy of the License at
%%% 
%%%     http://www.apache.org/licenses/LICENSE-2.0
%%% 
%%% Unless required by applicable law or agreed to in writing, software
%%% distributed under the License is distributed on an "AS IS" BASIS,
%%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%%% See the License for the specific language governing permissions and
%%% limitations under the License.
-module(lpad_json).

-export([load/1]).

load(File) ->
    parse(read_file(File)).

read_file(File) ->
    handle_read_file(file:read_file(File), File).

handle_read_file({ok, Bin}, _File) ->
    Bin;
handle_read_file({error, Err}, File) ->
    error({read_file, File, Err}).

parse(Bin) ->
    JSON = jiffy:decode(Bin),
    {handle_headers(ej:get({"headers"}, JSON)), handle_body(ej:get({"body"}, JSON))}. 

handle_headers(Headers) ->
    acc_headers(Headers, #{}).

acc_headers([], Acc) -> Acc;
acc_headers([ {[{Key, Value}]} | T], Acc) ->
    New = maps:put(binary_to_list(Key), binary_to_list(Value), Acc),
    acc_headers(T, New);
acc_headers([ H | _T ], _Acc) ->
    error({invalid_json_headers, H}).
    
handle_body(Body) ->
    binary_to_list(Body).
