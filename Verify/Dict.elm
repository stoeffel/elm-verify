module Verify.Dict exposing (ifEmpty)

{-| Functions to verify properties of a Dict.

@docs ifEmpty

-}

import Dict exposing (Dict)
import Verify exposing (Validator)


{-| Fails if a Dict is empty.

    import Dict

    ifEmpty "error" <| Dict.empty
    --> Err [ "error" ]

    ifEmpty "error" <| Dict.fromList [ (1, 1) ]
    --> Ok <| Dict.fromList [ (1, 1) ]

-}
ifEmpty : error -> Validator error (Dict a b) (Dict a b)
ifEmpty error input =
    if Dict.isEmpty input then
        Err [ error ]
    else
        Ok input
