module Verify.Set exposing (ifEmpty)

{-| Functions to verify properties of a Set.

@docs ifEmpty

-}

import Set exposing (Set)
import Verify exposing (Validator)


{-| Fails if a Set is empty.

    import Set

    ifEmpty "error" <| Set.empty
    --> Err [ "error" ]

    ifEmpty "error" <| Set.fromList [ (1, 1) ]
    --> Ok <| Set.fromList [ (1, 1) ]

-}
ifEmpty : error -> Validator error (Set a) (Set a)
ifEmpty error input =
    if Set.isEmpty input then
        Err [ error ]
    else
        Ok input
