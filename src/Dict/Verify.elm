module Dict.Verify exposing (notEmpty)

{-| Functions to verify properties of a Dict.

@docs notEmpty

-}

import Dict exposing (Dict)
import Verify exposing (Validator)


{-| Fails if a Dict is empty.

    import Dict

    notEmpty "error" <| Dict.empty
    --> Err ( "error" , [])

    notEmpty "error" <| Dict.fromList [ (1, 1) ]
    --> Ok <| Dict.fromList [ (1, 1) ]

-}
notEmpty : error -> Validator error (Dict a b) (Dict a b)
notEmpty error input =
    if Dict.isEmpty input then
        Err ( error, [] )

    else
        Ok input
