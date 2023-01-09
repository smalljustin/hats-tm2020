<?php

/*
 * Copyright (c) 2022 Keira Dueck <sylae@calref.net>
 * Use of this source code is governed by the MIT license, which
 * can be found in the LICENSE file.
 */

namespace Handler;

class APIListHats extends \HandlerBase
{

    public static function registerRoutes(): array
    {
        return [
            [['GET'], '/api/hats']
        ];
    }

    public function respond(array $vars)
    {
        if (strlen($_GET['apiKey'] ?? "") > 0) {
            try {
                $user = \User::createFromAPIKey($this->trs, $_GET['apiKey']);
                $this->trs->log("user_keystatus", user: $user);
            } catch (\InvalidArgumentException $e) {
                // we'll ignore invalid key and treat as guest
                $user = null;
            }
        } else {
            $user = null;
        }

        try {
            $hats = \Hat::getPubAndUserHats($this->trs, $user);

            header("Content-Type: application/json");
            echo json_encode($hats->values()->all());

        } catch (\Throwable $e) {
            $this->apiError("Unknown error. Please try again", 500, $e->getMessage());
        }
    }
}
