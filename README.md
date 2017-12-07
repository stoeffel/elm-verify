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
     Verify.ok VerifiedModel
         |> keep .id
         |> verify .firstName (Maybe.Verify.isJust "error")
         |> verify .lastName (Maybe.Verify.isJust"error")
```
