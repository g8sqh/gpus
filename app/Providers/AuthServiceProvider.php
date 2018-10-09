<?php

namespace App\Providers;

use Illuminate\Auth\GenericUser;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\ServiceProvider;

class AuthServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     *
     * @return void
     */
    public function register()
    {
        //
    }

    /**
     * Boot the authentication services for the application.
     *
     * @return void
     */
    public function boot()
    {
        // Here you may define how you wish users to be authenticated for your Lumen
        // application. The callback which receives the incoming request instance
        // should return either a User instance or null. You're free to obtain
        // the User instance via an API token or any other method necessary.

        $this->app['auth']->viaRequest('api', function ($request) {
            if ($request->getUser() && $request->getPassword()) {
                return $this->getUser($request->getUser(), $request->getPassword());
            }
        });
    }

    /**
     * Get the user with the given name and password.
     *
     * @param string $username
     * @param string $password
     *
     * @return GenericUser|null
     */
    protected function getUser($username, $password)
    {
        foreach (config('users.credentials') as $user) {
            if ($username === $user[0]) {
                if (app('hash')->check($password, $user[1])) {
                    return new GenericUser(['name' => $user[0]]);
                }

                return;
            }
        }
    }
}
