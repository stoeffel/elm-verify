module Verify
    exposing
        ( Validator
        , andThen
        , compose
        , custom
        , fail
        , fromMaybe
        , keep
        , ok
        , validate
        , verify
        )

{-| Verify allows you to validate a model into a structure that makes forbidden states impossible.

@docs Validator, ok, fail, validate, verify, keep, custom, compose, andThen, fromMaybe

-}


{-| This is just an alias for a function from an input to a result.
The result is either:

  - contains a list of all errors that didn't satisfy the given spec.
  - contains an verified structure.

-}
type alias Validator error input verified =
    input -> Result (List error) verified


{-| This allows you to lift any value into a validator.
This is particularly useful to initialize a pipeline.

    ok "always ok" Nothing
    --> Ok "always ok"

-}
ok : finally -> Validator error input finally
ok f _ =
    Ok f


{-| Allows you to create a failing Validator.

    fail "always fail" Nothing
    --> Err [ "always fail" ]

-}
fail : error -> Validator error input verified
fail error _ =
    Err [ error ]


{-| Allows you to start a validation pipeline. It is a synonym for `Verify.ok`, intended to make
things clearer to read.

    import Maybe.Verify exposing (isJust)


    type alias User =
        { id : Int
        , firstName : String
        }

    validator : Validator String { a | id : Int, firstName : Maybe String } User
    validator =
        validate User
            |> keep .id
            |> verify .firstName (isJust "You need to provide a first name.")

    validator { id = 1, firstName = Nothing }
    --> Err [ "You need to provide a first name." ]

    validator { id = 1, firstName = Just "Stöffel" }
    --> Ok { id = 1, firstName = "Stöffel" }

-}
validate : finally -> Validator error input finally
validate =
    ok


{-| Allows you to verify a part of a structure.

    import Maybe.Verify exposing (isJust)


    validator : Validator String { a | firstName : Maybe String } String
    validator =
        validate identity
            |> verify .firstName (isJust "You need to provide a first name.")

    validator { firstName = Nothing }
    --> Err [ "You need to provide a first name." ]

    validator { firstName = Just "Stöffel" }
    --> Ok "Stöffel"

-}
verify :
    (bigger -> smaller)
    -> Validator error smaller verified
    -> Validator error bigger (verified -> finally)
    -> Validator error bigger finally
verify f v1 v2 =
    v2 |> custom (f >> v1)


{-| You can use `keep` if you want a value to be in the verified structure without any verification.

    import Maybe.Verify exposing (isJust)


    validator : Validator String { a | id : Int, firstName : Maybe String } (Int, String)
    validator =
        validate (,)
            |> keep .id
            |> verify .firstName (isJust "You need to provide a first name.")


    validator { id = 1, firstName = Nothing }
    --> Err [ "You need to provide a first name." ]

    validator { id = 1, firstName = Just "Stöffel" }
    --> Ok (1, "Stöffel")

-}
keep :
    (bigger -> smaller)
    -> Validator error bigger (smaller -> finally)
    -> Validator error bigger finally
keep f v =
    v |> custom (f >> Ok)


{-| Sometimes the verification of a part only makes sense in a bigger context.
This means your Validator needs access to the whole structure.

    import Maybe.Verify exposing (isJust)


    validator : Validator String { a | username : Maybe String, level: Int, strength: Int } (String, Int)
    validator =
        validate (,)
            |> verify .username (isJust "You need to provide a username.")
            |> custom (\{level, strength} ->
                if strength > level then
                    Err [ "Your strength can exceed your level." ]
                else
                    Ok strength
                )


    validator { username = Just "Ork1", level = 3, strength = 5 }
    --> Err [ "Your strength can exceed your level." ]

    validator { username = Just "Ork1", level = 6, strength = 5 }
    --> Ok ("Ork1", 5)

    validator { username = Nothing, level = 3, strength = 5 }
    --> Err [ "You need to provide a username."
    -->     , "Your strength can exceed your level."
    -->     ]

-}
custom :
    Validator error input verified
    -> Validator error input (verified -> finally)
    -> Validator error input finally
custom v2 v1 input =
    case ( v1 input, v2 input ) of
        ( Ok r1, Ok r2 ) ->
            Ok (r1 r2)

        ( Err e1, Err e2 ) ->
            Err (e1 ++ e2)

        ( Err e1, _ ) ->
            Err e1

        ( _, Err e2 ) ->
            Err e2


{-| This allows you to compose multible Validators.

    import Maybe.Verify exposing (isJust)
    import String.Verify exposing (notBlank)


    validator { firstName = Nothing }
    --> Err [ "You need to provide a first name." ]

    validator { firstName = Just "   " }
    --> Err [  "You need to provide a none empty first name." ]

    validator { firstName = Just "Stöffel" }
    --> Ok "Stöffel"

    validator : Validator String { a | firstName : Maybe String } String
    validator =
        validate identity
            |> verify .firstName verifyName

    verifyName : Validator String (Maybe String) String
    verifyName =
        isJust "You need to provide a first name."
            |> compose (notBlank "You need to provide a none empty first name.")

-}
compose :
    Validator error verified finally
    -> Validator error input verified
    -> Validator error input finally
compose v2 v1 =
    v1 >> Result.andThen v2


{-| This allows you to chain multible Validators.

    import Maybe.Verify exposing (isJust)


    validator { firstName = Nothing }
    --> Err [ "You need to provide a first name." ]

    validator { firstName = Just "   " }
    --> Err [  "Name is too short" ]

    validator { firstName = Just "Stöffel" }
    --> Ok "Stöffel"

    validator : Validator String { a | firstName : Maybe String } String
    validator =
        validate identity
            |> verify .firstName verifyName

    verifyName : Validator String (Maybe String) String
    verifyName =
        isJust "You need to provide a first name."
            |> andThen (\name ->
                if String.length name > 5 then
                    ok name
                else
                    fail "Name is too short"
            )

-}
andThen :
    (a -> Validator error input b)
    -> Validator error input a
    -> Validator error input b
andThen f v =
    \input ->
        case v input of
            Err e ->
                Err e

            Ok verified ->
                f verified input


{-| This is a convenient function to create a `Validator` from a function that returns a maybe instead of a `Result`.
It fails if the function returns a Nothing.
This allows you to verify a input and return a verified result of a different type.

    fromMaybe hasInitial "error" ""
    --> Err [ "error" ]

    fromMaybe hasInitial "error" "Christoph"
    --> Ok 'C'

    hasInitial : String -> Maybe Char
    hasInitial str =
        case String.uncons str of
            Just (initial, _) -> Just initial
            Nothing -> Nothing

-}
fromMaybe : (input -> Maybe verified) -> error -> Validator error input verified
fromMaybe f error =
    f >> Result.fromMaybe [ error ]
