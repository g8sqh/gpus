<?php

use Illuminate\Http\Request;

class AuthServiceProviderTest extends TestCase
{
    public function setUp()
    {
        parent::setUp();

        $this->app->router->post('authtest', ['middleware' => 'auth', function () {
            //
        }]);

        // Password is "password" for biigle and "password2" for biigle2
        putenv('USERS=biigle:$2y$10$Oe.BLL97aXyW5sWPlKeT5Oo3TtANDiQYiQ8RGDN/D2/9HuaxId1D.;biigle2:$2y$10$TKdCJ5z1j9./pazW9ZleKOA5s4nLtMQE7MSdG8M3IN7.m2ntEtck.');
    }

    public function testAuthFailed()
    {
        $this->post('authtest')->assertResponseStatus(401);

        $response = $this->call('POST', 'authtest', [], [], [], ['PHP_AUTH_USER' => 'biigle', 'PHP_AUTH_PW' => 'password2']);
        $this->assertEquals(401, $response->getStatusCode());
    }

    public function testAuthSuccess()
    {
        $response = $this->call('POST', 'authtest', [], [], [], ['PHP_AUTH_USER' => 'biigle', 'PHP_AUTH_PW' => 'password']);
        $this->assertEquals(200, $response->getStatusCode());

        $response = $this->call('POST', 'authtest', [], [], [], ['PHP_AUTH_USER' => 'biigle2', 'PHP_AUTH_PW' => 'password2']);
        $this->assertEquals(200, $response->getStatusCode());
    }
}
