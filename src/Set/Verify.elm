module Set.Verify exposing (notEmpty)

{-| Functions to verify properties of a Set.

@docs notEmpty

-}

import Set exposing (Set)
import Verify exposing (Validator)


{-| Fails if a Set is empty.

    import Set

    notEmpty "error" <| Set.empty
    --> Err [ "error" ]

    notEmpty "error" <| Set.fromList [ (1, 1) ]
    --> Ok <| Set.fromList [ (1, 1) ]

-}
notEmpty : error -> Validator error (Set a) (Set a)
notEmpty error input =
    if Set.isEmpty input then
        Err [ error ]

    else
        Ok input
