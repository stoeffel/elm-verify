# elm-verify

> Verify allows you to validate a model into a structure that makes forbidden states impossible.

## Example Use-Case

Your model is unvalidated, but on submit you want to verify your model and allow your function to submit that model to only take a verified model.

Your model would maybe look like this:

```elm
    type alias Model =
        { id : Int
        , firstName : Maybe String
        , lastName : Maybe String

        -- ...
        }
```

Your submit function would be: `submit : VerifiedModel -> Cmd msg -- not Model`

So you define `VerifiedModel` like this:

```elm
    type alias VerifiedModel =
        { id : Int
        , firstName : String
        , lastName : String

        -- ...
        }
```

and you can verify this by using a `Json.Decode.Pipeline`-like api.

```elm
     validator : Validator String Model VerifiedModel
     validator =
        validate VerifiedModel
            |> keep .id
            |> verify .firstName (Maybe.Verify.isJust "no first name")
            |> verify .lastName (Maybe.Verify.isJust "no last name")
```

You can execute a `Validator` just by calling it.

```elm
    validator { id = 1, firstName = Just "Luke", lastName = Just "Skywalker" }
    --> Ok { id = 1, firstName = "Luke", lastName = "Skywalker" }

    validator { id = 1, firstName = Nothing, lastName = Nothing }
    --> Err ( "no first name", ["no last name"])
```

So far we've used `Validator`s from `Maybe.Verify`. There are other `Validator`s in this package, but it's also simple to write your own `Validator`.

```elm
  possitiveNumber : error -> Validator error Int Int
  possitiveNumber error input =
    if input >= 0 then
       Ok input
    else
       Err ( error , [])
```
