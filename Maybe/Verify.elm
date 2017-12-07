module Maybe.Verify exposing (isJust)

{-| Functions to verify properties of a Maybe.

@docs isJust

-}

import Verify exposing (Validator)


{-| Fails if a Maybe is Nothing.

    isJust "error" Nothing
    --> Err [ "error" ]


    isJust "error" (Just 42)
    --> Ok 42 -- It removes the wrapper as well!

-}
isJust : error -> Validator error (Maybe a) a
isJust error =
    Result.fromMaybe [ error ]
