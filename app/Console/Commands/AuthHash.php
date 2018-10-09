<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;

class AuthHash extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'auth:hash {password : Password to hash}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Get a hash of a user password';

    /**
     * Handle the command.
     *
     * @return void
     */
    public function handle()
    {
        $hash = app('hash')->make($this->argument('password'));
        $this->comment($hash);
    }
}
