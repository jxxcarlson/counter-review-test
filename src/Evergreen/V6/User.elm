module Evergreen.V6.User exposing (..)

import Evergreen.V6.EmailAddress
import Time


type alias EmailString =
    String


type Role
    = AdminRole
    | UserRole


type alias User =
    { id : String
    , fullname : String
    , username : String
    , email : Evergreen.V6.EmailAddress.EmailAddress
    , emailString : EmailString
    , created_at : Time.Posix
    , updated_at : Time.Posix
    , roles : List Role
    , verified : Maybe Time.Posix
    , recentLoginEmails : List Time.Posix
    }


type alias SignInData =
    { username : String
    , email : EmailString
    , name : String
    , roles : List Role
    }


type alias Username =
    String


type alias Id =
    String
