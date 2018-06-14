module List.Verify exposing (notEmpty)

{-| Functions to verify properties of a List.

@docs notEmpty

-}

import Verify exposing (Validator)


{-| Fails if a List is empty.

    notEmpty "error" []
    --> Err [ "error" ]

    notEmpty "error" [1]
    --> Ok ( 1, [] )

-}
notEmpty : error -> Validator error (List a) ( a, List a )
notEmpty error input =
    case input of
        [] ->
            Err [ error ]

        head :: tail ->
            Ok ( head, tail )
