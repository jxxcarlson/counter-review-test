module Atmospheric exposing (gotNumbers)

import Dict
import Lamdera
import LocalUUID
import MagicLink.Helper as Helper
import Types



-- gotNumbers : (Types.BackendModel, Cmd msg)


gotNumbers : Types.BackendModel -> Result error String -> ( Types.BackendModel, Cmd msg )
gotNumbers model tryRandomAtmosphericNumbers =
    let
        randomNumbers =
            case tryRandomAtmosphericNumbers of
                Err _ ->
                    [ 235880, 700828, 253400, 602641 ]

                Ok rns ->
                    let
                        parts : List Int
                        parts =
                            rns
                                |> String.split "\t"
                                |> List.map String.trim
                                |> List.filterMap String.toInt

                        data : Maybe LocalUUID.Data
                        data =
                            LocalUUID.initFrom4List parts
                    in
                    parts
    in
    case LocalUUID.initFrom4List randomNumbers of
        Nothing ->
            let
                _ =
                    Debug.log "XX gotNumbers: could not construct localUuidData" True
            in
            -- TODO: should send error message to the user, but no clientId avaiilable here
            ( model, Cmd.none )

        Just localUuidData ->
            ( { model
                | randomAtmosphericNumbers = Just randomNumbers
                , localUuidData = Just localUuidData
                , users =
                    if Dict.isEmpty model.users then
                        Helper.testUserDictionary

                    else
                        model.users
                , userNameToEmailString =
                    if Dict.isEmpty model.userNameToEmailString then
                        Dict.fromList [ ( "jxxcarlson", "jxxcarlson@gmail.com" ), ( "aristotle", "jxxcarlson@mac.com" ) ]

                    else
                        model.userNameToEmailString
              }
            , Cmd.none
            )


finishUp model data parts =
    case data of
        Nothing ->
            let
                _ =
                    Debug.log "XX gotNumbers: could not construct localUuidData" True
            in
            -- TODO: should send error message to the user, but no clientId avaiilable here
            ( model, Cmd.none )

        Just localUuidData ->
            let
                numbers : List Int
                numbers =
                    parts

                _ =
                    Debug.log "XX gotNumbers: COULD construct localUuidData" True
            in
            ( { model
                | randomAtmosphericNumbers = Just numbers
                , localUuidData = Just localUuidData
                , users =
                    if Dict.isEmpty model.users then
                        Helper.testUserDictionary

                    else
                        model.users
                , userNameToEmailString =
                    if Dict.isEmpty model.userNameToEmailString then
                        Dict.fromList [ ( "jxxcarlson", "jxxcarlson@gmail.com" ), ( "aristotle", "jxxcarlson@mac.com" ) ]

                    else
                        model.userNameToEmailString
              }
            , Cmd.none
            )
