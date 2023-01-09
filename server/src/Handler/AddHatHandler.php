<?php

/*
 * Copyright (c) 2022 Keira Dueck <sylae@calref.net>
 * Use of this source code is governed by the MIT license, which
 * can be found in the LICENSE file.
 */

namespace Handler;

class AddHatHandler extends \HandlerBase
{

    public static function registerRoutes(): array
    {
        return [
            [['POST', 'GET'], '/hats']
        ];
    }

    public function respond(array $vars)
    {
        if (!$this->trs->user->isLogged) {
            $this->unauthorizedMessage();
            return;
        }

        if (array_key_exists("submit", $_POST)) {
            // adding a hat time
        }

        $vars['hats'] = \Hat::getHatsByUser($this->trs, $this->trs->user);

        echo $this->trs->twig->render("personalHatPage.twig", $vars);
    }
}
