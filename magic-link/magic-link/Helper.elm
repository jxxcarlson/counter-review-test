module Helper exposing
    ( getAtmosphericRandomNumbers
    , handleAtmosphericNumbers
    , testUserDictionary
    , trigger
    )

import Dict
import EmailAddress
import Http
import LocalUUID
import Task
import Time
import Types
import User


trigger : msg -> Cmd msg
trigger msg =
    Task.perform (always msg) Time.now


testUserDictionary : Dict.Dict User.EmailString User.User
testUserDictionary =
    Dict.fromList
        [ ( "jxxcarlson@gmail.com"
          , { fullname = "Jim Carlson"
            , username = "jxxcarlson"
            , email = EmailAddress.EmailAddress { domain = "gmail", localPart = "jxxcarlson", tags = [], tld = [ "com" ] }
            , emailString = "jxxcarlson@gmail.com"
            , id = "661b76d8-eee8-42fb-a28d-cf8ada73f869"
            , created_at = Time.millisToPosix 1704237963000
            , updated_at = Time.millisToPosix 1704237963000
            , roles = [ User.AdminRole, User.UserRole ]
            , recentLoginEmails = []
            , verified = Nothing
            }
          )
        , ( "jxxcarlson@mac.com"
          , { fullname = "Aristotle"
            , username = "aristotle"
            , email = EmailAddress.EmailAddress { domain = "mac", localPart = "jxxcarlson", tags = [], tld = [ "com" ] }
            , emailString = "jxxcarlson@mac.com"
            , id = "38952d62-9772-4e5d-a927-b8e41b6ef2ed"
            , created_at = Time.millisToPosix 1704237963000
            , updated_at = Time.millisToPosix 1704237963000
            , roles = [ User.UserRole ]
            , recentLoginEmails = []
            , verified = Nothing
            }
          )
        ]


getAtmosphericRandomNumbers : Cmd Types.BackendMsg
getAtmosphericRandomNumbers =
    Http.get
        { url = LocalUUID.randomNumberUrl 4 9
        , expect = Http.expectString Types.GotAtmosphericRandomNumbers
        }


handleAtmosphericNumbers : Types.BackendModel -> Result error String -> ( Types.BackendModel, Cmd Types.BackendMsg )
handleAtmosphericNumbers model tryRandomAtmosphericNumbers =
    let
        ( numbers, data_ ) =
            case tryRandomAtmosphericNumbers of
                Err _ ->
                    ( model.randomAtmosphericNumbers, model.localUuidData )

                Ok rns ->
                    let
                        parts =
                            rns
                                |> String.split "\t"
                                |> List.map String.trim
                                |> List.filterMap String.toInt

                        data =
                            LocalUUID.initFrom4List parts
                    in
                    ( Just parts, data )
    in
    ( { model
        | randomAtmosphericNumbers = numbers
        , localUuidData = data_
        , users =
            if Dict.isEmpty model.users then
                testUserDictionary

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
