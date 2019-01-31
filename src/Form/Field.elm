module Form.Field exposing (Field(..), errors, fail, faulty, init, map, mapError, value)

{-| -}


{-| -}
type Field error value
    = Failure error (List error) value
    | Success value


{-| -}
init : value -> Field error value
init =
    Success


{-| -}
value : Field error value -> value
value field =
    case field of
        Failure _ _ v ->
            v

        Success v ->
            v


{-| -}
fail : error -> List error -> value -> Field error value
fail =
    Failure


{-| -}
map : (a -> b) -> Field error a -> Field error b
map f field =
    case field of
        Failure e es v ->
            Failure e es (f v)

        Success v ->
            Success (f v)


{-| -}
mapError : (a -> b) -> Field a value -> Field b value
mapError f field =
    case field of
        Failure e es v ->
            Failure (f e) (List.map f es) v

        Success v ->
            Success v


{-| -}
faulty : Field error value -> Bool
faulty field =
    case field of
        Failure e es v ->
            True

        Success v ->
            False


{-| -}
errors : Field error value -> List error
errors field =
    case field of
        Failure e es v ->
            e :: es

        Success v ->
            []
