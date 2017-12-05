module Verify.List exposing (ifEmpty)

{-| Functions to verify properties of a List.

@docs ifEmpty

-}

import Verify exposing (Validator)


{-| Fails if a List is empty.

    ifEmpty "error" []
    --> Err [ "error" ]

    ifEmpty "error" [1]
    --> Ok [1]

-}
ifEmpty : error -> Validator error (List a) (List a)
ifEmpty error input =
    case input of
        [] ->
            Err [ error ]

        _ ->
            Ok input
