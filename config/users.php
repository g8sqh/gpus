<?php

return [

   /*
    |--------------------------------------------------------------------------
    | Users that are authorized to access the application
    |--------------------------------------------------------------------------
    |
    | This application does not use a database to store user information. Instead,
    | there is a fixed configuration string in the format:
    | "<username>:<password hash>;<username>:<password hash>"
    |
    */

   'credentials' => array_map(function ($info) {
      return explode(':', $info);
   }, explode(';', env('USER_CREDENTIALS', ''))),

];
